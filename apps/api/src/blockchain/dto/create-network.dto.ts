import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsIn, IsOptional, IsString, IsUrl, Length } from 'class-validator';
export class CreateNetworkDto {
  @ApiProperty({ example: 'solana-devnet' }) @IsString() @Length(3, 50) key: string;
  @ApiProperty({ example: 'Solana Devnet' }) @IsString() @Length(3, 80) name: string;
  @ApiProperty({ enum: ['devnet', 'testnet', 'mainnet-beta'] }) @IsIn(['devnet', 'testnet', 'mainnet-beta']) cluster: string;
  @ApiProperty({ example: 'https://api.devnet.solana.com' }) @IsUrl({ require_tld: false }) rpcUrl: string;
  @ApiProperty({ required: false, default: true }) @IsOptional() @IsBoolean() enabled?: boolean;
}
