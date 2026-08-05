import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsString, IsUUID, Length, Max, Min } from 'class-validator';
export class CreateOrderDto {
  @ApiProperty() @IsUUID() itemId: string;
  @ApiProperty() @IsString() @Length(32, 64) walletAddress: string;
  @ApiProperty({ default: 1 }) @IsInt() @Min(1) @Max(10) quantity: number;
  @ApiProperty() @IsString() @Length(12, 100) idempotencyKey: string;
}
