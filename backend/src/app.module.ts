import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import * as Joi from 'joi';
import { PrismaModule } from './prisma.module';
import { AuthModule } from './auth/auth.module';
import { ReportsModule } from './reports/reports.module';
import { MatchesModule } from './matches/matches.module';
import { SightingsModule } from './sightings/sightings.module';
import { FavoritesModule } from './favorites/favorites.module';
import { ActivityModule } from './activity/activity.module';
import { AiModule } from './ai/ai.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, validationSchema: Joi.object({ DATABASE_URL: Joi.string().required(), JWT_ACCESS_SECRET: Joi.string().min(16).required(), JWT_REFRESH_SECRET: Joi.string().min(16).optional(), JWT_ACCESS_TTL: Joi.string().optional(), JWT_REFRESH_TTL: Joi.string().optional() }) }),
    PrismaModule,
    AuthModule,
    ReportsModule,
    MatchesModule,
    SightingsModule,
    FavoritesModule,
    ActivityModule,
    AiModule,
  ],
})
export class AppModule {}
