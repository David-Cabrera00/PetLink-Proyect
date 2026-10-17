import { IsISO8601, IsNumber, IsOptional, IsString, Max, Min, MinLength } from 'class-validator';
export class CreateSightingDto { @IsNumber() @Min(-90) @Max(90) latitude!: number; @IsNumber() @Min(-180) @Max(180) longitude!: number; @IsString() @MinLength(1) description!: string; @IsOptional() @IsString() photoUrl?: string; @IsOptional() @IsISO8601() seenAt?: string; }
