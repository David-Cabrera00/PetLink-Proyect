import { Controller, Get, HttpCode } from '@nestjs/common';

@Controller('health')
export class HealthController {
  @Get()
  @HttpCode(200)
  check() {
    return {
      status: 'ok',
      service: 'petlink-api',
      timestamp: new Date().toISOString(),
    };
  }
}
