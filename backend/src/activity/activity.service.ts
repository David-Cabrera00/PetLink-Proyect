import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
@Injectable()
export class ActivityService { constructor(private readonly prisma: PrismaService) {} async list(userId: string) { const reports = await this.prisma.petReport.findMany({ where: { ownerId: userId }, orderBy: { updatedAt: 'desc' }, take: 50, select: { id: true, name: true, status: true, type: true, updatedAt: true, createdAt: true } }); return reports.map((report) => ({ id: report.id, type: 'report', title: `Reporte de ${report.name}`, status: report.status.toLowerCase(), reportType: report.type.toLowerCase(), createdAt: report.updatedAt })); } }
