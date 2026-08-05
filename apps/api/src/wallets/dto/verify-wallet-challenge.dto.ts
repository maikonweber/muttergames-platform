import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsUUID, Length } from 'class-validator';

export class VerifyWalletChallengeDto {
  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  challengeId!: string;

  @ApiProperty({ description: 'Assinatura ed25519 em base58' })
  @IsString()
  @Length(64, 128)
  signature!: string;
}
