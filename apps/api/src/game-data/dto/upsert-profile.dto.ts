import { ApiProperty } from '@nestjs/swagger';
import { IsObject } from 'class-validator';

export class UpsertProfileDto {
  @ApiProperty({ type: Object, additionalProperties: true })
  @IsObject()
  data!: Record<string, unknown>;
}
