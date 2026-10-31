import {
  Body,
  Controller,
  Post,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiConsumes, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AiService } from './ai.service';

@ApiTags('ai')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('ai')
export class AiController {
  constructor(private readonly ai: AiService) {}

  @Post('analyze-image')
  @UseInterceptors(FileInterceptor('file'))
  @ApiConsumes('multipart/form-data', 'application/json')
  analyzeImage(
    @UploadedFile() file?: { originalname: string; mimetype: string; buffer: Buffer; size: number },
    @Body() body?: { imageUrl?: string; imageBase64?: string },
  ) {
    return this.ai.analyzePetImage({
      file,
      imageUrl: body?.imageUrl,
      imageBase64: body?.imageBase64,
    });
  }
}
