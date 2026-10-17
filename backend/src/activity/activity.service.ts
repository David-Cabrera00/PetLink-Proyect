import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

type ActivityEvent = {
  id: string;
  type: string;
  title: string;
  status: string;
  reportType: string;
  createdAt: Date;
};

@Injectable()
export class ActivityService {
  constructor(private readonly prisma: PrismaService) {}

  async list(userId: string): Promise<ActivityEvent[]> {
    const [reports, notifications] = await Promise.all([
      this.prisma.petReport.findMany({
        where: { ownerId: userId },
        orderBy: { updatedAt: 'desc' },
        take: 50,
        select: { id: true, name: true, status: true, type: true, updatedAt: true },
      }),
      this.prisma.notification.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        take: 50,
        select: {
          reportId: true,
          type: true,
          title: true,
          createdAt: true,
          report: { select: { status: true, type: true } },
        },
      }),
    ]);

    return [
      ...reports.map((report): ActivityEvent => ({
        id: report.id,
        type: 'report',
        title: `Reporte de ${report.name}`,
        status: report.status.toLowerCase(),
        reportType: report.type.toLowerCase(),
        createdAt: report.updatedAt,
      })),
      ...notifications
        .filter((notification) => notification.reportId && notification.report)
        .map((notification): ActivityEvent => ({
          id: notification.reportId!,
          type: notification.type,
          title: notification.title,
          status: notification.report!.status.toLowerCase(),
          reportType: notification.report!.type.toLowerCase(),
          createdAt: notification.createdAt,
        })),
    ]
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())
      .slice(0, 50);
  }
}
