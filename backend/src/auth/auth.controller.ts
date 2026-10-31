import { Body, Controller, Get, HttpCode, Patch, Post, Req, UploadedFile, UseGuards, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { ChangePasswordDto, ForgotPasswordDto, LoginDto, RefreshTokenDto, RegisterDto, ResetPasswordDto, UpdateProfileDto } from './dto';
import { JwtAuthGuard } from './jwt-auth.guard';

@ApiTags('auth') @Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}
  @Post('register') register(@Body() dto: RegisterDto) { return this.auth.register(dto); }
  @Post('login') login(@Body() dto: LoginDto) { return this.auth.login(dto); }
  @Post('refresh') @HttpCode(200) refresh(@Body() dto: RefreshTokenDto) { return this.auth.refresh(dto); }
  @Post('forgot-password') forgotPassword(@Body() dto: ForgotPasswordDto) { return this.auth.forgotPassword(dto); }
  @Post('reset-password') resetPassword(@Body() dto: ResetPasswordDto) { return this.auth.resetPassword(dto); }
  @ApiBearerAuth() @UseGuards(JwtAuthGuard) @Get('me') me(@Req() req: { user: { sub: string } }) { return this.auth.me(req.user.sub); }
  @ApiBearerAuth() @UseGuards(JwtAuthGuard) @Patch('me') updateProfile(@Req() req: { user: { sub: string } }, @Body() dto: UpdateProfileDto) { return this.auth.updateProfile(req.user.sub, dto); }
  @ApiBearerAuth() @UseGuards(JwtAuthGuard) @Post('me/avatar') @UseInterceptors(FileInterceptor('file')) uploadAvatar(@Req() req: { user: { sub: string } }, @UploadedFile() file: { originalname: string; mimetype: string; buffer: Buffer }) { return this.auth.uploadAvatar(req.user.sub, file); }
  @ApiBearerAuth() @UseGuards(JwtAuthGuard) @Patch('password') changePassword(@Req() req: { user: { sub: string } }, @Body() dto: ChangePasswordDto) { return this.auth.changePassword(req.user.sub, dto); }
}
