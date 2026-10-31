import { ConflictException, Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from '../prisma.service';
import { ChangePasswordDto, LoginDto, RefreshTokenDto, RegisterDto, UpdateProfileDto } from './dto';

type TokenUser = { id: string; email: string };
type TokenType = 'access' | 'refresh';

@Injectable()
export class AuthService {
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
}
