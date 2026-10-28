import { Controller, Get, Patch, Param, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ActivityService } from './activity.service';

@ApiTags('activity')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('activity')
export class ActivityController {
  constructor(private readonly activity: ActivityService) {}

  @Get()
  @ApiOperation({ summary: 'List user activity events and notifications' })
  list(@Req() req: any) {
    return this.activity.list(req.user.sub);
  }

  @Patch('read-all')
  @ApiOperation({ summary: 'Mark all notifications as read' })
  markAllAsRead(@Req() req: any) {
    return this.activity.markAllAsRead(req.user.sub);
  }

  @Patch('notifications/:id/read')
  @ApiOperation({ summary: 'Mark a single notification as read' })
  markAsRead(@Req() req: any, @Param('id') id: string) {
    return this.activity.markAsRead(req.user.sub, id);
  }
}
