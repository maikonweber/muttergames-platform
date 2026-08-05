import { Body, Controller, Get, Post, Version } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser, type AuthUser } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { RegisterDto } from './dto/register.dto';

@ApiTags('auth')
@Controller()
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Public()
  @Post('auth/register')
  @Version('1')
  @ApiOperation({ summary: 'Registra um jogador MutterGames' })
  register(@Body() dto: RegisterDto) {
    return this.auth.register(dto);
  }

  @Public()
  @Post('auth/login')
  @Version('1')
  @ApiOperation({ summary: 'Login com email/username e senha' })
  login(@Body() dto: LoginDto) {
    return this.auth.login(dto);
  }

  @Public()
  @Post('auth/refresh')
  @Version('1')
  @ApiOperation({ summary: 'Renova access token' })
  refresh(@Body() dto: RefreshTokenDto) {
    return this.auth.refresh(dto.refreshToken);
  }

  @Public()
  @Post('auth/logout')
  @Version('1')
  @ApiOperation({ summary: 'Revoga refresh token' })
  logout(@Body() dto: RefreshTokenDto) {
    return this.auth.logout(dto.refreshToken);
  }

  @Get('me')
  @Version('1')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Perfil do jogador autenticado' })
  me(@CurrentUser() user: AuthUser) {
    return this.auth.me(user.userId);
  }
}
