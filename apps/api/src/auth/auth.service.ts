import {
  ConflictException,
  Inject,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { createHash, randomBytes } from 'node:crypto';
import { and, eq, gt, isNull, or } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.constants';
import type { DrizzleDb } from '../drizzle/drizzle.module';
import { refreshTokens, users } from '../drizzle/schema';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

@Injectable()
export class AuthService {
  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDb,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
  ) {}

  async register(dto: RegisterDto) {
    const existing = await this.db
      .select({ id: users.id })
      .from(users)
      .where(or(eq(users.email, dto.email.toLowerCase()), eq(users.username, dto.username.toLowerCase())))
      .limit(1);
    if (existing.length) throw new ConflictException('Email or username already in use');

    const passwordHash = await bcrypt.hash(dto.password, 12);
    const [user] = await this.db
      .insert(users)
      .values({
        email: dto.email.toLowerCase(),
        username: dto.username.toLowerCase(),
        displayName: dto.displayName ?? dto.username,
        passwordHash,
        status: 'active',
      })
      .returning({
        id: users.id,
        email: users.email,
        username: users.username,
        displayName: users.displayName,
        status: users.status,
        createdAt: users.createdAt,
      });

    const tokens = await this.issueTokens(user);
    return { user, ...tokens };
  }

  async login(dto: LoginDto) {
    const login = dto.login.toLowerCase();
    const [user] = await this.db
      .select()
      .from(users)
      .where(or(eq(users.email, login), eq(users.username, login)))
      .limit(1);
    if (!user || user.status !== 'active') throw new UnauthorizedException('Invalid credentials');

    const ok = await bcrypt.compare(dto.password, user.passwordHash);
    if (!ok) throw new UnauthorizedException('Invalid credentials');

    const tokens = await this.issueTokens(user);
    return {
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        displayName: user.displayName,
        status: user.status,
        createdAt: user.createdAt,
      },
      ...tokens,
    };
  }

  async refresh(refreshToken: string) {
    const tokenHash = this.hashToken(refreshToken);
    const [row] = await this.db
      .select()
      .from(refreshTokens)
      .where(
        and(
          eq(refreshTokens.tokenHash, tokenHash),
          isNull(refreshTokens.revokedAt),
          gt(refreshTokens.expiresAt, new Date()),
        ),
      )
      .limit(1);
    if (!row) throw new UnauthorizedException('Invalid refresh token');

    await this.db
      .update(refreshTokens)
      .set({ revokedAt: new Date() })
      .where(eq(refreshTokens.id, row.id));

    const [user] = await this.db.select().from(users).where(eq(users.id, row.userId)).limit(1);
    if (!user || user.status !== 'active') throw new UnauthorizedException('User inactive');
    return this.issueTokens(user);
  }

  async logout(refreshToken: string) {
    const tokenHash = this.hashToken(refreshToken);
    await this.db
      .update(refreshTokens)
      .set({ revokedAt: new Date() })
      .where(eq(refreshTokens.tokenHash, tokenHash));
    return { ok: true };
  }

  async me(userId: string) {
    const [user] = await this.db
      .select({
        id: users.id,
        email: users.email,
        username: users.username,
        displayName: users.displayName,
        status: users.status,
        createdAt: users.createdAt,
      })
      .from(users)
      .where(eq(users.id, userId))
      .limit(1);
    if (!user) throw new UnauthorizedException();
    return user;
  }

  private async issueTokens(user: { id: string; email: string; username: string }) {
    const accessToken = await this.jwt.signAsync({
      sub: user.id,
      email: user.email,
      username: user.username,
    });
    const refreshToken = randomBytes(48).toString('base64url');
    const days = Number(this.config.get('JWT_REFRESH_DAYS', 30));
    const expiresAt = new Date(Date.now() + days * 86_400_000);
    await this.db.insert(refreshTokens).values({
      userId: user.id,
      tokenHash: this.hashToken(refreshToken),
      expiresAt,
    });
    return {
      accessToken,
      refreshToken,
      tokenType: 'Bearer',
      expiresIn: this.config.get('JWT_EXPIRES_IN', '1h'),
    };
  }

  private hashToken(token: string) {
    return createHash('sha256').update(token).digest('hex');
  }
}
