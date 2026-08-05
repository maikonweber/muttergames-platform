import { ApiProperty } from '@nestjs/swagger';
import { IsIn, IsObject, IsOptional, IsString, IsUUID, Length } from 'class-validator';

export class CreateChainIntentDto {
  @ApiProperty({ enum: ['reward_claim', 'market_buy', 'transfer'] })
  @IsIn(['reward_claim', 'market_buy', 'transfer'])
  kind!: string;

  @ApiProperty()
  @IsString()
  @Length(32, 64)
  walletAddress!: string;

  @ApiProperty({ required: false, default: 'solana-devnet' })
  @IsOptional()
  @IsString()
  networkKey?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsUUID()
  gameId?: string;

  @ApiProperty({ type: Object, additionalProperties: true })
  @IsObject()
  payload!: Record<string, unknown>;
}
