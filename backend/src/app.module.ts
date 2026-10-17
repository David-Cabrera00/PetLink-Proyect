import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import * as Joi from 'joi';
import { PrismaService } from './prisma.service';
import { AuthModule } from './auth/auth.module';
import { ReportsModule } from './reports/reports.module';
import { MatchesModule } from './matches/matches.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, validationSchema: Joi.object({ DATABASE_URL: Joi.string().required(), JWT_ACCESS_SECRET: Joi.string().min(16).required() }) }),
    AuthModule,
    ReportsModule,
    MatchesModule,
  ],
  providers: [PrismaService],
  exports: [PrismaService],
})
export class AppModule {}
