import { Body, Controller, Delete, Get, Param, Patch, Post, Query, Req, UploadedFile, UseGuards, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateReportDto, ListReportsDto, UpdateReportDto } from './dto';
import { ReportsService } from './reports.service';

@ApiTags('reports') @ApiBearerAuth() @UseGuards(JwtAuthGuard) @Controller('reports')
export class ReportsController {
  constructor(private readonly reports: ReportsService) {}
  @Get() list(@Req() req:any,@Query() dto:ListReportsDto){return this.reports.list(req.user.sub,dto);}
  @Get('mine') mine(@Req() req:any,@Query() dto:ListReportsDto){return this.reports.list(req.user.sub,dto,true);}
  @Get(':id') get(@Req() req:any,@Param('id') id:string){return this.reports.get(id, req.user.sub);}
  @Post() create(@Req() req:any,@Body() dto:CreateReportDto){return this.reports.create(req.user.sub,dto);}
  @Patch(':id') update(@Req() req:any,@Param('id') id:string,@Body() dto:UpdateReportDto){return this.reports.update(id,req.user.sub,dto);}
  @Delete(':id') remove(@Req() req:any,@Param('id') id:string){return this.reports.remove(id,req.user.sub);}
  @Post(':id/photos') @UseInterceptors(FileInterceptor('file')) uploadPhoto(@Req() req:any,@Param('id') id:string,@UploadedFile() file: { originalname: string; mimetype: string; buffer: Buffer; size: number }){return this.reports.uploadPhoto(id,req.user.sub,file);}
}
