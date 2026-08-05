import { ApiProperty } from '@nestjs/swagger';
import { IsIn, IsOptional, IsString, Length, Matches } from 'class-validator';

export class CreateGameDto {
  @ApiProperty({ example: 'fallen-tactics' })
  @Matches(/^[a-z0-9-]+$/)
  @Length(3, 80)
  slug!: string;

  @ApiProperty({ example: 'Fallen Tactics' })
  @IsString()
  @Length(3, 100)
  name!: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  @Length(0, 2000)
  description?: string;

  @ApiProperty({ required: false, enum: ['active', 'coming_soon', 'archived'] })
  @IsOptional()
  @IsIn(['active', 'coming_soon', 'archived'])
  status?: string;
}
