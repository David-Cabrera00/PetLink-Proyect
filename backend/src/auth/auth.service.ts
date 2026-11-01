import { BadRequestException, ConflictException, Injectable, Logger, NotFoundException, UnauthorizedException } from '@nestjs/common';
import * as nodemailer from 'nodemailer';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from '../prisma.service';
import { ChangePasswordDto, ForgotPasswordDto, GoogleAuthDto, LoginDto, RefreshTokenDto, RegisterDto, ResetPasswordDto, UpdateProfileDto } from './dto';

type TokenUser = { id: string; email: string };
type TokenType = 'access' | 'refresh';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  constructor(private readonly prisma: PrismaService, private readonly jwt: JwtService) {}
  private safe(user: { id: string; name: string; email: string; avatarUrl: string | null }) { return { id: user.id, name: user.name, email: user.email, avatarUrl: user.avatarUrl }; }

  private secretFor(type: TokenType) {
    return type === 'access'
      ? process.env.JWT_ACCESS_SECRET
      : (process.env.JWT_REFRESH_SECRET ?? process.env.JWT_ACCESS_SECRET);
  }

  private sign(user: TokenUser, type: TokenType) {
    const ttl = type === 'access'
      ? (process.env.JWT_ACCESS_TTL ?? '15m')
      : (process.env.JWT_REFRESH_TTL ?? '60d');
    return this.jwt.sign(
      { sub: user.id, email: user.email, typ: type },
      { secret: this.secretFor(type), expiresIn: ttl as any },
    );
  }

  private tokens(user: TokenUser) {
    return {
      accessToken: this.sign(user, 'access'),
      refreshToken: this.sign(user, 'refresh'),
    };
  }

  async register(dto: RegisterDto) {
    const email = dto.email.trim().toLowerCase();
    if (await this.prisma.user.findUnique({ where: { email } })) throw new ConflictException('Email already registered');
    const user = await this.prisma.user.create({ data: { name: dto.name.trim(), email, passwordHash: await bcrypt.hash(dto.password, 12) } });
    return { user: this.safe(user), ...this.tokens(user) };
  }
  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({ where: { email: dto.email.trim().toLowerCase() } });
    if (!user || !(await bcrypt.compare(dto.password, user.passwordHash))) throw new UnauthorizedException('Invalid credentials');
    return { user: this.safe(user), ...this.tokens(user) };
  }

  async googleAuth(dto: GoogleAuthDto) {
    try {
      const response = await fetch(`https://oauth2.googleapis.com/tokeninfo?id_token=${dto.idToken}`);
      if (!response.ok) {
        throw new UnauthorizedException('Token de Google inválido o expirado');
      }
      const payload: any = await response.json();

      const email = payload.email?.toLowerCase();
      if (!email || payload.email_verified === 'false' || payload.email_verified === false) {
        throw new BadRequestException('El correo de Google no está verificado');
      }

      const name = payload.name || payload.given_name || 'Usuario Google';
      const picture = payload.picture || null;

      let user = await this.prisma.user.findUnique({ where: { email } });
      if (!user) {
        const randomPassword = await bcrypt.hash(Math.random().toString(36) + Date.now(), 12);
        user = await this.prisma.user.create({
          data: {
            name,
            email,
            passwordHash: randomPassword,
            avatarUrl: picture,
          },
        });
      } else if (!user.avatarUrl && picture) {
        user = await this.prisma.user.update({
          where: { id: user.id },
          data: { avatarUrl: picture },
        });
      }

      return { user: this.safe(user), ...this.tokens(user) };
    } catch (err: any) {
      if (err instanceof UnauthorizedException || err instanceof BadRequestException) {
        throw err;
      }
      this.logger.error(`[GOOGLE AUTH ERROR] ${err.message}`);
      throw new UnauthorizedException('Error al validar con Google');
    }
  }
  async refresh(dto: RefreshTokenDto) {
    let payload: { sub?: string; typ?: string };
    try {
      payload = this.jwt.verify(dto.refreshToken, { secret: this.secretFor('refresh') });
    } catch {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }
    if (payload.typ !== 'refresh' || !payload.sub) throw new UnauthorizedException('Invalid refresh token');
    const user = await this.prisma.user.findUnique({ where: { id: payload.sub } });
    if (!user) throw new UnauthorizedException('Invalid refresh token');
    return { user: this.safe(user), ...this.tokens(user) };
  }
  async me(id: string) { const user = await this.prisma.user.findUniqueOrThrow({ where: { id } }); return this.safe(user); }
  async changePassword(id: string, dto: ChangePasswordDto) {
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id } });
    if (!(await bcrypt.compare(dto.currentPassword, user.passwordHash))) throw new UnauthorizedException('Invalid current password');
    await this.prisma.user.update({ where: { id }, data: { passwordHash: await bcrypt.hash(dto.newPassword, 12) } });
    return { success: true };
  }
  async updateProfile(id: string, dto: UpdateProfileDto) { const user = await this.prisma.user.update({ where: { id }, data: { name: dto.name.trim() } }); return this.safe(user); }
  async uploadAvatar(id: string, file?: { originalname: string; mimetype: string; buffer: Buffer }) {
    if (!file) throw new NotFoundException('Avatar file is required');
    const baseUrl = process.env.SUPABASE_URL;
    const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
    const bucket = process.env.SUPABASE_STORAGE_BUCKET ?? 'pet-photos';
    if (!baseUrl || !serviceKey) throw new Error('Supabase Storage is not configured');
    const storagePath = `avatars/${id}/${Date.now()}-${file.originalname.replace(/[^a-zA-Z0-9._-]/g, '_')}`;
    const response = await fetch(`${baseUrl}/storage/v1/object/${bucket}/${storagePath}`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${serviceKey}`, apikey: serviceKey, 'Content-Type': file.mimetype, 'x-upsert': 'false' },
      body: new Uint8Array(file.buffer),
    });
    if (!response.ok) throw new Error(`Storage upload failed (${response.status})`);
    const avatarUrl = `${baseUrl}/storage/v1/object/public/${bucket}/${storagePath}`;
    const user = await this.prisma.user.update({ where: { id }, data: { avatarUrl } });
    return this.safe(user);
  }

  async forgotPassword(dto: ForgotPasswordDto) {
    const email = dto.email.trim().toLowerCase();
    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) {
      return { success: true, message: 'Si el correo está registrado, recibirás un código de recuperación.' };
    }

    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const codeHash = await bcrypt.hash(code, 10);
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutos

    await this.prisma.passwordReset.deleteMany({ where: { email } });
    await this.prisma.passwordReset.create({
      data: { email, codeHash, expiresAt },
    });

    // Disparar envío de correo en segundo plano para que la app responda al instante
    this.sendResetEmail(email, user.name, code).catch((err) => {
      this.logger.error(`[RESET EMAIL BACKGROUND ERROR] ${err.message}`);
    });
    return { success: true, message: 'Código de recuperación enviado' };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const email = dto.email.trim().toLowerCase();
    const record = await this.prisma.passwordReset.findFirst({
      where: {
        email,
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!record) {
      throw new BadRequestException('El código es inválido o ha expirado');
    }

    const isValid = await bcrypt.compare(dto.code.trim(), record.codeHash);
    if (!isValid) {
      throw new BadRequestException('El código de verificación es incorrecto');
    }

    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }

    const newPasswordHash = await bcrypt.hash(dto.newPassword, 12);
    await this.prisma.user.update({
      where: { email },
      data: { passwordHash: newPasswordHash },
    });

    await this.prisma.passwordReset.deleteMany({ where: { email } });
    return { success: true, message: 'Contraseña restablecida correctamente' };
  }

  private async sendResetEmail(to: string, name: string, code: string) {
    const smtpUser = process.env.SMTP_USER;
    const smtpPass = process.env.SMTP_PASS;
    const resendKey = process.env.RESEND_API_KEY;

    const htmlBody = `
      <div style="font-family: Arial, sans-serif; max-width: 520px; margin: 0 auto; padding: 24px; border: 1px solid #EADFD6; border-radius: 16px; background-color: #FBF6F1;">
        <h2 style="color: #4A2D4A; margin-bottom: 8px;">Recuperación de contraseña</h2>
        <p style="color: #6E5C67; font-size: 15px;">Hola <strong>${name}</strong>,</p>
        <p style="color: #6E5C67; font-size: 15px;">Has solicitado restablecer tu contraseña en PetLink. Ingresa este código de 6 dígitos en la aplicación:</p>
        <div style="background-color: #4A2D4A; color: #FFFFFF; font-size: 32px; font-weight: bold; letter-spacing: 8px; text-align: center; padding: 18px; border-radius: 12px; margin: 24px 0;">
          ${code}
        </div>
        <p style="color: #8E7D87; font-size: 13px;">Este código expirará en 15 minutos. Si no solicitaste este cambio, puedes ignorar este mensaje.</p>
        <p style="color: #E07A5F; font-size: 13px; font-weight: bold;">El equipo de PetLink · Cada huella cuenta</p>
      </div>
    `;

    // 1. Prioridad: Gmail SMTP vía Nodemailer (envía a cualquier dominio de correo sin costo)
    if (smtpUser && smtpPass) {
      try {
        const transporter = nodemailer.createTransport({
          host: 'smtp.gmail.com',
          port: 465,
          secure: true,
          auth: {
            user: smtpUser,
            pass: smtpPass.replace(/\s+/g, ''),
          },
          connectionTimeout: 10000,
          greetingTimeout: 10000,
          socketTimeout: 15000,
        });

        await transporter.sendMail({
          from: process.env.SMTP_FROM ?? `PetLink <${smtpUser}>`,
          to,
          subject: `${code} es tu código de recuperación de PetLink`,
          html: htmlBody,
        });

        this.logger.log(`[PASSWORD RESET] Correo enviado exitosamente a ${to} vía Gmail SMTP`);
        return;
      } catch (err: any) {
        this.logger.error(`[SMTP ERROR] Falló el envío a ${to}: ${err.message}`);
      }
    }

// 2. Fallback: Brevo API (HTTPS)
    const brevoKey = process.env.BREVO_API_KEY;
    if (brevoKey) {
      try {
        const brevoResponse = await fetch('https://api.brevo.com/v3/smtp/email', {
          method: 'POST',
          headers: {
            'api-key': brevoKey,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            sender: {
              email: process.env.EMAIL_FROM ?? 'petlink@example.com',
              name: 'PetLink',
            },
            to: [{ email: to, name }],
            subject: `${code} es tu código de recuperación de PetLink`,
            htmlContent: htmlBody,
          }),
        });
        if (brevoResponse.ok) {
          this.logger.log(`[PASSWORD RESET] Correo enviado a ${to} vía Brevo`);
          return;
        }
        const errText = await brevoResponse.text();
        this.logger.error(`[BREVO ERROR] Status ${brevoResponse.status}: ${errText}`);
      } catch (err: any) {
        this.logger.error('[BREVO EXCEPTION]', err.message);
      }
    }

    // 3. Fallback: Resend API
    if (resendKey) {
      try {
        const response = await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${resendKey}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            from: process.env.EMAIL_FROM ?? 'PetLink <onboarding@resend.dev>',
            to: [to],
            subject: `${code} es tu código de recuperación de PetLink`,
            html: htmlBody,
          }),
        });
        if (response.ok) {
          this.logger.log(`[PASSWORD RESET] Correo enviado a ${to} vía Resend`);
          return;
        }
        this.logger.error(`[RESEND ERROR] Status ${response.status}: ${await response.text()}`);
      } catch (err: any) {
        this.logger.error('[RESEND EXCEPTION]', err.message);
      }
    }

    // 3. Fallback en consola para desarrollo
    console.log(`\n========================================`);
    console.log(`[PASSWORD RESET DEV] Para ${to}: CÓDIGO = ${code}`);
    console.log(`========================================\n`);
  }
}
