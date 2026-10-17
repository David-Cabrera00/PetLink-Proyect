import { ConflictException, Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from '../prisma.service';
import { ChangePasswordDto, LoginDto, RegisterDto, UpdateProfileDto } from './dto';

@Injectable()
export class AuthService {
  constructor(private readonly prisma: PrismaService, private readonly jwt: JwtService) {}
  private safe(user: { id: string; name: string; email: string; avatarUrl: string | null }) { return { id: user.id, name: user.name, email: user.email, avatarUrl: user.avatarUrl }; }
  private token(user: { id: string; email: string }) {
    const ttl = process.env.JWT_ACCESS_TTL ?? '15m';
    return this.jwt.sign(
      { sub: user.id, email: user.email },
      { secret: process.env.JWT_ACCESS_SECRET, expiresIn: ttl as any },
    );
  }
  async register(dto: RegisterDto) {
    const email = dto.email.trim().toLowerCase();
    if (await this.prisma.user.findUnique({ where: { email } })) throw new ConflictException('Email already registered');
    const user = await this.prisma.user.create({ data: { name: dto.name.trim(), email, passwordHash: await bcrypt.hash(dto.password, 12) } });
    return { user: this.safe(user), accessToken: this.token(user) };
  }
  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({ where: { email: dto.email.trim().toLowerCase() } });
    if (!user || !(await bcrypt.compare(dto.password, user.passwordHash))) throw new UnauthorizedException('Invalid credentials');
    return { user: this.safe(user), accessToken: this.token(user) };
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
