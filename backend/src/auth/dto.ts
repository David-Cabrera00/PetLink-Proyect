import { IsEmail, IsString, Matches, MinLength } from 'class-validator';

export class RegisterDto { @IsString() @MinLength(2) name!: string; @IsEmail() email!: string; @IsString() @MinLength(8) @Matches(/^\S+$/, { message: 'Password cannot contain spaces' }) password!: string; }
export class LoginDto { @IsEmail() email!: string; @IsString() @MinLength(1) @Matches(/^\S+$/, { message: 'Password cannot contain spaces' }) password!: string; }
export class ChangePasswordDto { @IsString() @MinLength(1) currentPassword!: string; @IsString() @MinLength(8) newPassword!: string; }
export class UpdateProfileDto { @IsString() @MinLength(2) name!: string; }
