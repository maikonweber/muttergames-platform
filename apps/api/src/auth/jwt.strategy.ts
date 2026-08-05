import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import type { AuthUser } from '../common/decorators/current-user.decorator';

type JwtPayload = { sub: string; email: string; username: string };

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(config: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.get('JWT_SECRET', 'muttergames-dev-secret-change-me'),
    });
  }

  validate(payload: JwtPayload): AuthUser {
    return { userId: payload.sub, email: payload.email, username: payload.username };
  }
}
