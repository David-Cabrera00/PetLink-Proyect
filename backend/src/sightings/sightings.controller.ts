import { Body, Controller, Delete, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateSightingDto } from './dto';
import { SightingsService } from './sightings.service';
@ApiTags('sightings') @ApiBearerAuth() @UseGuards(JwtAuthGuard) @Controller('reports/:reportId/sightings')
export class SightingsController { constructor(private readonly sightings: SightingsService) {} @Get() list(@Param('reportId') reportId: string) { return this.sightings.list(reportId); } @Post() create(@Param('reportId') reportId: string, @Req() req: any, @Body() dto: CreateSightingDto) { return this.sightings.create(reportId, req.user.sub, dto); } @Delete(':id') remove(@Param('id') id: string, @Req() req: any) { return this.sightings.remove(id, req.user.sub); } }
