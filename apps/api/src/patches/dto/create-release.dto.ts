import { ApiProperty } from '@nestjs/swagger';
import { IsIn, IsInt, IsOptional, IsString, IsUrl, Length, Matches, Min } from 'class-validator';

export class CreateReleaseDto {
  @ApiProperty({ enum: ['windows'], default: 'windows' })
  @IsIn(['windows'])
  platform!: string;

  @ApiProperty({ enum: ['stable', 'beta'], default: 'stable' })
  @IsIn(['stable', 'beta'])
  channel!: string;

  @ApiProperty({ example: '0.1.0' })
  @Matches(/^\d+\.\d+\.\d+(-[a-z0-9.]+)?$/i)
  version!: string;

  @ApiProperty()
  @IsUrl({ require_tld: false })
  downloadUrl!: string;

  @ApiProperty()
  @Matches(/^[a-f0-9]{64}$/i)
  sha256!: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsInt()
  @Min(1)
  sizeBytes?: number;

  @ApiProperty({ example: 'FallenTactics.exe' })
  @IsString()
  @Length(1, 260)
  executablePath!: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  @Length(0, 5000)
  releaseNotes?: string;
}
