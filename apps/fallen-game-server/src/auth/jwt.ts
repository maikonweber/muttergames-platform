import jwt from 'jsonwebtoken';
import { config } from '../config';

export type AuthUser = {
  userId: string;
  username: string;
  email?: string;
};

export function verifyOptionalToken(token?: string): AuthUser | null {
  if (!token) {
    if (config.requireAuth) throw new Error('AUTH_REQUIRED');
    return null;
  }

  try {
    const payload = jwt.verify(token, config.jwtSecret) as {
      sub: string;
      username?: string;
      email?: string;
    };
    return {
      userId: payload.sub,
      username: payload.username ?? payload.sub.slice(0, 8),
      email: payload.email,
    };
  } catch {
    if (config.requireAuth) throw new Error('AUTH_INVALID');
    return null;
  }
}
