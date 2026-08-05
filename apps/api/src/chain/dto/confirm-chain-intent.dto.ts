import { ApiProperty } from '@nestjs/swagger';
import { IsString, Length } from 'class-validator';

export class ConfirmChainIntentDto {
  @ApiProperty({ description: 'Solana transaction signature' })
  @IsString()
  @Length(64, 128)
  txSignature!: string;
}
