import { ApiProperty } from '@nestjs/swagger';
import { IsString, Length } from 'class-validator';

export class LoginDto {
  @ApiProperty({ description: 'Email or username', example: 'tactician' })
  @IsString()
  @Length(3, 255)
  login!: string;

  @ApiProperty({ example: 'Str0ngP@ss!' })
  @IsString()
  @Length(8, 128)
  password!: string;
}
