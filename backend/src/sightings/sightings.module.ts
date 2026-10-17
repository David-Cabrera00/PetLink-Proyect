import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { SightingsController } from './sightings.controller';
import { SightingsService } from './sightings.service';
@Module({ imports: [AuthModule], controllers: [SightingsController], providers: [SightingsService] }) export class SightingsModule {}
