import { Module } from '@nestjs/common';
import { MutterCoinsController } from './mutter-coins.controller';
import { MutterCoinsService } from './mutter-coins.service';

@Module({ controllers: [MutterCoinsController], providers: [MutterCoinsService], exports: [MutterCoinsService] })
export class MutterCoinsModule {}
