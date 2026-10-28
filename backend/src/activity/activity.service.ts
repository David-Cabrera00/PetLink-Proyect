import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

export type ActivityEvent = {
  id: string;
  reportId: string;
  type: string;
  title: string;
  body?: string | null;
  status: string;
  reportType: string;
  isRead: boolean;
  readAt?: Date | null;
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
          id: true,
          reportId: true,
          type: true,
          title: true,
          body: true,
          readAt: true,
          createdAt: true,
          report: { select: { status: true, type: true } },
        },
      }),
    ]);

    return [
      ...reports.map((report): ActivityEvent => ({
        id: report.id,
        reportId: report.id,
        type: 'report',
        title: `Reporte de ${report.name}`,
        status: report.status.toLowerCase(),
        reportType: report.type.toLowerCase(),
        isRead: true,
        readAt: report.updatedAt,
        createdAt: report.updatedAt,
      })),
      ...notifications
        .filter((notification) => notification.reportId && notification.report)
        .map((notification): ActivityEvent => ({
          id: notification.id,
          reportId: notification.reportId!,
          type: notification.type,
          title: notification.title,
          body: notification.body,
          status: notification.report!.status.toLowerCase(),
          reportType: notification.report!.type.toLowerCase(),
          isRead: notification.readAt !== null,
          readAt: notification.readAt,
          createdAt: notification.createdAt,
        })),
    ]
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())
      .slice(0, 50);
  }

  async markAsRead(userId: string, notificationId: string): Promise<{ success: boolean }> {
    await this.prisma.notification.updateMany({
      where: { id: notificationId, userId },
      data: { readAt: new Date() },
    });
    return { success: true };
  }

  async markAllAsRead(userId: string): Promise<{ success: boolean; count: number }> {
    const result = await this.prisma.notification.updateMany({
      where: { userId, readAt: null },
      data: { readAt: new Date() },
    });
    return { success: true, count: result.count };
  }
}
