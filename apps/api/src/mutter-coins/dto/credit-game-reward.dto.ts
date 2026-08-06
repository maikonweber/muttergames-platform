import { ApiProperty } from '@nestjs/swagger';
import { IsObject, IsOptional, IsString, IsUUID, Length, Matches } from 'class-validator';

export class CreditGameRewardDto {
  @ApiProperty({ example: 'fallen-tactics' })
  @IsString()
  @Length(2, 100)
  gameId!: string;

  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  userId!: string;

  @ApiProperty({ example: '5000000000', description: 'Unidades atômicas (9 decimais)' })
  @Matches(/^\d+$/)
  amountAtomic!: string;

  @ApiProperty({ example: 'Vitória em partida ranqueada' })
  @IsString()
  @Length(3, 160)
  description!: string;

  @ApiProperty({ example: 'match:4c7d10e4-6f46-4ea7-93ee-e50493e8af21:reward' })
  @IsString()
  @Length(8, 128)
  idempotencyKey!: string;

  @ApiProperty({ required: false, type: Object, additionalProperties: true })
  @IsOptional()
  @IsObject()
  metadata?: Record<string, unknown>;
}
