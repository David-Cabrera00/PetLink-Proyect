import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { MatchesService } from './matches.service';
@ApiTags('matches') @ApiBearerAuth() @UseGuards(JwtAuthGuard) @Controller('matches') export class MatchesController { constructor(private readonly matches:MatchesService){} @Get() list(@Req() req:any){return this.matches.list(req.user.sub);} }
