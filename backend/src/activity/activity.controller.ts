import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ActivityService } from './activity.service';
@ApiTags('activity') @ApiBearerAuth() @UseGuards(JwtAuthGuard) @Controller('activity') export class ActivityController { constructor(private readonly activity: ActivityService) {} @Get() list(@Req() req: any) { return this.activity.list(req.user.sub); } }
