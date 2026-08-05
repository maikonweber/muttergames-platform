import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDate,
  IsObject,
  IsOptional,
  IsString,
  IsUUID,
  Length,
  Matches,
} from 'class-validator';

export class IngestGameEventDto {
  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  eventId!: string;

  @ApiProperty({ example: 'match.completed' })
  @IsString()
  @Length(3, 80)
  type!: string;

  @ApiProperty({ example: '0.1.0' })
  @Matches(/^\d+\.\d+\.\d+(-[a-z0-9.]+)?$/i)
  buildVersion!: string;

  @ApiProperty()
  @Type(() => Date)
  @IsDate()
  occurredAt!: Date;

  @ApiProperty({ type: Object, additionalProperties: true })
  @IsObject()
  payload!: Record<string, unknown>;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  payloadHash?: string;

  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  idempotencyKey!: string;
}
