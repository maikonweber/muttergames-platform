import { ApiProperty } from '@nestjs/swagger';
import { IsIn, IsInt, IsOptional, IsString, IsUrl, Length, Matches, Max, Min } from 'class-validator';

export class CreateMarketplaceItemDto {
  @ApiProperty()
  @Matches(/^[a-z0-9-]+$/)
  @Length(3, 80)
  slug!: string;

  @ApiProperty()
  @IsString()
  @Length(3, 100)
  name!: string;

  @ApiProperty()
  @IsString()
  @Length(10, 1000)
  description!: string;

  @ApiProperty({ example: 'fallen-tactics', description: 'Game UUID or slug (tenant)' })
  @IsString()
  @Length(3, 80)
  gameId!: string;

  @ApiProperty({ enum: ['skin', 'collectible', 'equipment', 'pass'] })
  @IsIn(['skin', 'collectible', 'equipment', 'pass'])
  assetType!: string;

  @ApiProperty({ example: '25000000' })
  @Matches(/^\d+$/)
  priceAtomic!: string;

  @ApiProperty({ example: 'USDC' })
  @IsString()
  @Length(2, 10)
  currencySymbol!: string;

  @ApiProperty({ example: 500 })
  @IsInt()
  @Min(1)
  @Max(1_000_000)
  supply!: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsUrl({ require_tld: false })
  imageUrl?: string;
}
