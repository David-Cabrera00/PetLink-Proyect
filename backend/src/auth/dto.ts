import { IsEmail, IsString, Length, Matches, MinLength } from 'class-validator';

export class RegisterDto { @IsString() @MinLength(2) name!: string; @IsEmail() email!: string; @IsString() @MinLength(8) @Matches(/^\S+$/, { message: 'Password cannot contain spaces' }) password!: string; }
export class LoginDto { @IsEmail() email!: string; @IsString() @MinLength(1) @Matches(/^\S+$/, { message: 'Password cannot contain spaces' }) password!: string; }
export class ChangePasswordDto { @IsString() @MinLength(1) currentPassword!: string; @IsString() @MinLength(8) newPassword!: string; }
export class RefreshTokenDto { @IsString() @MinLength(10) refreshToken!: string; }
export class UpdateProfileDto { @IsString() @MinLength(2) name!: string; }
export class ForgotPasswordDto { @IsEmail() email!: string; }
export class ResetPasswordDto { @IsEmail() email!: string; @IsString() @Length(6, 6) code!: string; @IsString() @MinLength(8) @Matches(/^\S+$/, { message: 'Password cannot contain spaces' }) newPassword!: string; }
export class GoogleAuthDto { @IsString() idToken!: string; }

