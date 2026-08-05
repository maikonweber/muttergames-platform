import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString, Length, Matches } from 'class-validator';

export class RegisterDto {
  @ApiProperty({ example: 'player@muttergames.com' })
  @IsEmail()
  email!: string;

  @ApiProperty({ example: 'tactician' })
  @Matches(/^[a-z0-9_]{3,32}$/)
  username!: string;

  @ApiProperty({ example: 'Str0ngP@ss!' })
  @IsString()
  @Length(8, 128)
  password!: string;

  @ApiProperty({ required: false, example: 'Tactician' })
  @IsString()
  @Length(1, 80)
  displayName?: string;
}
