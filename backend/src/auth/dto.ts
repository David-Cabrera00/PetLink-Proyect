import { IsEmail, IsString, MinLength } from 'class-validator';

export class RegisterDto { @IsString() @MinLength(2) name!: string; @IsEmail() email!: string; @IsString() @MinLength(8) password!: string; }
export class LoginDto { @IsEmail() email!: string; @IsString() @MinLength(1) password!: string; }
export class ChangePasswordDto { @IsString() @MinLength(1) currentPassword!: string; @IsString() @MinLength(8) newPassword!: string; }
