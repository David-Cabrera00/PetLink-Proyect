import { Body, Controller, Get, Param, Patch, Post, Query, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateReportDto, ListReportsDto, UpdateReportDto } from './dto';
import { ReportsService } from './reports.service';

@ApiTags('reports') @ApiBearerAuth() @UseGuards(JwtAuthGuard) @Controller('reports')
export class ReportsController {
  constructor(private readonly reports: ReportsService) {}
  @Get() list(@Req() req:any,@Query() dto:ListReportsDto){return this.reports.list(req.user.sub,dto);}
  @Get('mine') mine(@Req() req:any,@Query() dto:ListReportsDto){return this.reports.list(req.user.sub,dto,true);}
  @Get(':id') get(@Param('id') id:string){return this.reports.get(id);}
  @Post() create(@Req() req:any,@Body() dto:CreateReportDto){return this.reports.create(req.user.sub,dto);}
  @Patch(':id') update(@Req() req:any,@Param('id') id:string,@Body() dto:UpdateReportDto){return this.reports.update(id,req.user.sub,dto);}
}
