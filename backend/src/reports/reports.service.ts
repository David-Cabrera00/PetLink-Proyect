import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, ReportStatus } from '@prisma/client';
import { PrismaService } from '../prisma.service';
import { CreateReportDto, ListReportsDto, UpdateReportDto } from './dto';

@Injectable()
export class ReportsService {
  constructor(private readonly prisma: PrismaService) {}
  private distance(lat1: number, lon1: number, lat2: number, lon2: number) { const r=6371, dLat=(lat2-lat1)*Math.PI/180, dLon=(lon2-lon1)*Math.PI/180; const a=Math.sin(dLat/2)**2+Math.cos(lat1*Math.PI/180)*Math.cos(lat2*Math.PI/180)*Math.sin(dLon/2)**2; return 2*r*Math.asin(Math.sqrt(a)); }
  private present(r: any, origin?: { latitude?: number; longitude?: number }, viewerId?: string) { return { ...r, type: r.type.toLowerCase(), status: r.status.toLowerCase(), isOwner: viewerId != null && r.ownerId === viewerId, ownerEmail: r.owner?.email ?? null, distanceKm: origin?.latitude != null && origin.longitude != null ? this.distance(origin.latitude, origin.longitude, r.latitude, r.longitude) : 0, sightingsCount: r._count?.sightings ?? 0, pet: { id: r.id, name:r.name, species:r.species, breed:r.breed, sex:r.sex, age:r.age, size:r.size, color:r.color, description:r.description, primaryPhotoUrl:r.photos?.[0]?.url ?? null }, photos: r.photos }; }
  async list(userId: string, dto: ListReportsDto, mine = false) { const where: Prisma.PetReportWhereInput = { status: { not: ReportStatus.CLOSED }, ...(dto.type ? { type: dto.type } : {}), ...(mine ? { ownerId:userId } : {}) }; const rows=await this.prisma.petReport.findMany({ where, include:{ photos:true, _count:{select:{sightings:true}} }, orderBy:{createdAt:'desc'}, skip:(dto.page-1)*dto.limit, take:dto.limit }); const filtered=dto.radiusKm && dto.latitude != null && dto.longitude != null ? rows.filter(r=>this.distance(dto.latitude!,dto.longitude!,r.latitude,r.longitude)<=dto.radiusKm!) : rows; return { data: filtered.map(r=>this.present(r,dto)), page:dto.page, limit:dto.limit, hasMore:rows.length===dto.limit }; }
  async get(id: string, viewerId?: string) { const r=await this.prisma.petReport.findUnique({ where:{id}, include:{photos:true,owner:{select:{email:true}},sightings:{select:{id: true, latitude: true, longitude: true, description: true, photoUrl: true, createdAt: true}, orderBy:{createdAt:'desc'}},_count:{select:{sightings:true}}} }); if(!r) throw new NotFoundException('Report not found'); return this.present(r, undefined, viewerId); }
  async create(ownerId: string, dto: CreateReportDto) { const r=await this.prisma.petReport.create({ data:{ ownerId, type:dto.type as any, name:dto.name.trim(), species:dto.species, breed:dto.breed, sex:dto.sex, age:dto.age, size:dto.size, color:dto.color, description:dto.description, traits:dto.traits, latitude:dto.latitude, longitude:dto.longitude, address:dto.address, lastSeenAt:new Date(dto.lastSeenAt) }, include:{photos:true,_count:{select:{sightings:true}}} }); return this.present(r); }
  async update(id: string, ownerId: string, dto: UpdateReportDto) { const current=await this.prisma.petReport.findUnique({where:{id}}); if(!current) throw new NotFoundException('Report not found'); if(current.ownerId!==ownerId) throw new ForbiddenException(); const r=await this.prisma.petReport.update({where:{id},data:{ ...(dto.description !== undefined ? {description:dto.description} : {}), ...(dto.address !== undefined ? {address:dto.address} : {}), ...(dto.type !== undefined ? {type:dto.type as any} : {}), ...(dto.status !== undefined ? {status:dto.status as ReportStatus} : {}) },include:{photos:true,_count:{select:{sightings:true}}}}); return this.present(r); }
  async remove(id: string, ownerId: string) { const current = await this.prisma.petReport.findUnique({ where: { id } }); if (!current) throw new NotFoundException('Report not found'); if (current.ownerId !== ownerId) throw new ForbiddenException(); await this.prisma.petReport.delete({ where: { id } }); return { success: true }; }
  async uploadPhoto(id: string, ownerId: string, file?: { originalname: string; mimetype: string; buffer: Buffer; size: number }) {
    if (!file) throw new NotFoundException('Photo file is required');
    const report = await this.prisma.petReport.findUnique({ where: { id } });
    if (!report) throw new NotFoundException('Report not found');
    if (report.ownerId !== ownerId) throw new ForbiddenException();
    const baseUrl = process.env.SUPABASE_URL;
    const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
    const bucket = process.env.SUPABASE_STORAGE_BUCKET ?? 'pet-photos';
    if (!baseUrl || !serviceKey) throw new Error('Supabase Storage is not configured');
    const storagePath = `${ownerId}/${id}/${Date.now()}-${file.originalname.replace(/[^a-zA-Z0-9._-]/g, '_')}`;
    const response = await fetch(`${baseUrl}/storage/v1/object/${bucket}/${storagePath}`, { method: 'POST', headers: { Authorization: `Bearer ${serviceKey}`, apikey: serviceKey, 'Content-Type': file.mimetype, 'x-upsert': 'false' }, body: new Uint8Array(file.buffer) });
    if (!response.ok) {
      const detail = await response.text();
      throw new Error(`Storage upload failed (${response.status}): ${detail.slice(0, 500)}`);
    }
    const url = `${baseUrl}/storage/v1/object/public/${bucket}/${storagePath}`;
    const photo = await this.prisma.photo.create({ data: { reportId: id, url, storagePath, mimeType: file.mimetype, sizeBytes: file.size } });
    return photo;
  }
}
