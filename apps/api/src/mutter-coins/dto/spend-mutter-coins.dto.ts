import { ApiProperty } from '@nestjs/swagger';
import { IsObject, IsOptional, IsString, Length, Matches } from 'class-validator';

export class SpendMutterCoinsDto {
  @ApiProperty({ example: '250000000' })
  @Matches(/^\d+$/)
  amountAtomic!: string;

  @ApiProperty({ example: 'Compra de item no marketplace' })
  @IsString()
  @Length(3, 160)
  description!: string;

  @ApiProperty({ example: '9a12f5cb-8636-439b-aea6-b02d78b4f0a1' })
  @Matches(/^[a-zA-Z0-9_-]{8,128}$/)
  idempotencyKey!: string;

  @ApiProperty({ required: false, type: Object, additionalProperties: true })
  @IsOptional()
  @IsObject()
  metadata?: Record<string, unknown>;
}
