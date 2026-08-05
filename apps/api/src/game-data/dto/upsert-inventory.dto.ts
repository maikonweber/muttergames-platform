import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsObject, IsOptional, IsString, Length, Min } from 'class-validator';

export class UpsertInventoryDto {
  @ApiProperty({ example: 'genesis-tactician' })
  @IsString()
  @Length(2, 80)
  sku!: string;

  @ApiProperty()
  @IsString()
  @Length(2, 100)
  name!: string;

  @ApiProperty({ default: 1 })
  @IsInt()
  @Min(1)
  quantity!: number;

  @ApiProperty({ required: false, type: Object, additionalProperties: true })
  @IsOptional()
  @IsObject()
  metadata?: Record<string, unknown>;
}
