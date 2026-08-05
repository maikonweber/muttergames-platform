import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export const GameId = createParamDecorator((_data: unknown, ctx: ExecutionContext): string => {
  const request = ctx.switchToHttp().getRequest<{ params: { gameId?: string }; gameId?: string }>();
  return request.gameId ?? request.params.gameId ?? '';
});
