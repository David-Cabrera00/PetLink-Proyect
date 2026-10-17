import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateSightingDto } from './dto';

@Injectable()
export class SightingsService {
  constructor(private readonly prisma: PrismaService) {}

  list(reportId: string) {
    return this.prisma.sighting.findMany({
      where: { reportId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(reportId: string, reporterId: string, dto: CreateSightingDto) {
    const report = await this.prisma.petReport.findUnique({
      where: { id: reportId },
    });
    if (!report) throw new NotFoundException('Report not found');

    const sighting = await this.prisma.sighting.create({
      data: {
        reportId,
        reporterId,
        latitude: dto.latitude,
        longitude: dto.longitude,
        description: dto.description,
        photoUrl: dto.photoUrl,
        createdAt: dto.seenAt ? new Date(dto.seenAt) : undefined,
      },
    });

    if (report.ownerId !== reporterId) {
      await this.prisma.notification.create({
        data: {
          userId: report.ownerId,
          reportId: report.id,
          type: 'sighting',
          title: `Nuevo avistamiento de ${report.name}`,
          body: 'Alguien registró un avistamiento sobre tu reporte.',
        },
      });
    }

    return sighting;
  }

  async remove(id: string, reporterId: string) {
    const sighting = await this.prisma.sighting.findUnique({ where: { id } });
    if (!sighting) throw new NotFoundException('Sighting not found');
    if (sighting.reporterId !== reporterId) throw new ForbiddenException();
    await this.prisma.sighting.delete({ where: { id } });
    return { success: true };
  }
}
