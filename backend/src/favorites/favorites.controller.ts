import { Controller, Delete, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { FavoritesService } from './favorites.service';
@ApiTags('favorites') @ApiBearerAuth() @UseGuards(JwtAuthGuard) @Controller('favorites')
export class FavoritesController { constructor(private readonly favorites: FavoritesService) {} @Get() list(@Req() req: any) { return this.favorites.list(req.user.sub); } @Post(':reportId') add(@Req() req: any, @Param('reportId') reportId: string) { return this.favorites.add(req.user.sub, reportId); } @Delete(':reportId') remove(@Req() req: any, @Param('reportId') reportId: string) { return this.favorites.remove(req.user.sub, reportId); } }
