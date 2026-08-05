import { ApiProperty } from '@nestjs/swagger';
import { IsIn, IsOptional, IsString, IsUUID, Length } from 'class-validator';

export class CreateWalletChallengeDto {
  @ApiProperty()
  @IsString()
  @Length(32, 64)
  address!: string;

  @ApiProperty({ enum: ['solana:devnet', 'solana:testnet', 'solana:mainnet-beta'] })
  @IsIn(['solana:devnet', 'solana:testnet', 'solana:mainnet-beta'])
  chain!: string;

  @ApiProperty({ required: false, description: 'Associa challenge ao user (opcional se autenticado)' })
  @IsOptional()
  @IsUUID()
  userId?: string;
}
