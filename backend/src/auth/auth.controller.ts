import { Body, Controller, Get, Patch, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { ChangePasswordDto, LoginDto, RegisterDto, UpdateProfileDto } from './dto';
import { JwtAuthGuard } from './jwt-auth.guard';

@ApiTags('auth') @Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}
  @Post('register') register(@Body() dto: RegisterDto) { return this.auth.register(dto); }
  @Post('login') login(@Body() dto: LoginDto) { return this.auth.login(dto); }
  @ApiBearerAuth() @UseGuards(JwtAuthGuard) @Get('me') me(@Req() req: { user: { sub: string } }) { return this.auth.me(req.user.sub); }
  @ApiBearerAuth() @UseGuards(JwtAuthGuard) @Patch('me') updateProfile(@Req() req: { user: { sub: string } }, @Body() dto: UpdateProfileDto) { return this.auth.updateProfile(req.user.sub, dto); }
  @ApiBearerAuth() @UseGuards(JwtAuthGuard) @Patch('password') changePassword(@Req() req: { user: { sub: string } }, @Body() dto: ChangePasswordDto) { return this.auth.changePassword(req.user.sub, dto); }
}
