import { IsEnum, IsISO8601, IsNumber, IsOptional, IsString, Max, MaxLength, Min, MinLength } from 'class-validator';

export enum ApiReportType { lost = 'LOST', found = 'FOUND' }
export class CreateReportDto {
  @IsEnum(ApiReportType) type!: ApiReportType;
  @IsString() @MinLength(1) name!: string; @IsString() species!: string; @IsString() breed!: string; @IsString() sex!: string; @IsString() age!: string; @IsString() size!: string; @IsString() color!: string;
  @IsString() @MinLength(1) @MaxLength(4000) description!: string; @IsOptional() @IsString() traits?: string;
  @IsNumber() @Min(-90) @Max(90) latitude!: number; @IsNumber() @Min(-180) @Max(180) longitude!: number; @IsString() address!: string; @IsISO8601() lastSeenAt!: string;
}
export class ListReportsDto { @IsOptional() @IsEnum(ApiReportType) type?: ApiReportType; @IsOptional() @IsNumber() @Min(0) @Max(1000) radiusKm?: number; @IsOptional() @IsNumber() @Min(-90) @Max(90) latitude?: number; @IsOptional() @IsNumber() @Min(-180) @Max(180) longitude?: number; @IsOptional() @IsNumber() @Min(1) @Max(100) page = 1; @IsOptional() @IsNumber() @Min(1) @Max(100) limit = 20; }
export class UpdateReportDto { @IsOptional() @IsString() description?: string; @IsOptional() @IsString() address?: string; @IsOptional() @IsEnum(ApiReportType) type?: ApiReportType; @IsOptional() @IsString() status?: 'ACTIVE'|'RECOVERED'|'CLOSED'; }
