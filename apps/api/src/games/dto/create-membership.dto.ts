import { ApiProperty } from '@nestjs/swagger';
import { IsIn, IsUUID } from 'class-validator';

export class CreateMembershipDto {
  @ApiProperty()
  @IsUUID()
  userId!: string;

  @ApiProperty({ enum: ['player', 'dev', 'admin'], default: 'player' })
  @IsIn(['player', 'dev', 'admin'])
  role!: string;
}
