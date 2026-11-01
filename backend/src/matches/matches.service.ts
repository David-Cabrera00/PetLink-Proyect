import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class MatchesService {
  constructor(private readonly prisma: PrismaService) {}

  private presentReport(r: any) {
    return {
      ...r,
      type: r.type.toLowerCase(),
      status: r.status.toLowerCase(),
      ownerEmail: r.owner?.email ?? null,
      pet: {
        id: r.id,
        name: r.name,
        species: r.species,
        breed: r.breed,
        sex: r.sex,
        age: r.age,
        size: r.size,
        color: r.color,
        description: r.description,
        primaryPhotoUrl: r.photos?.[0]?.url ?? null,
      },
      photos: r.photos ?? [],
    };
  }

  async list(userId: string) {
    const reports = await this.prisma.petReport.findMany({
      where: { ownerId: userId, status: 'ACTIVE' },
      include: { photos: true },
    });
    const other = await this.prisma.petReport.findMany({
      where: { ownerId: { not: userId }, status: 'ACTIVE' },
      include: { photos: true, owner: { select: { email: true } } },
    });

    return reports.flatMap((lost) =>
      other
        .filter(
          (found) =>
            found.type !== lost.type &&
            found.species.trim().toLowerCase() === lost.species.trim().toLowerCase(),
        )
        .map((found) => {
          const traits: string[] = ['species'];
          if (lost.breed && found.breed && lost.breed.trim().toLowerCase() === found.breed.trim().toLowerCase()) {
            traits.push('breed');
          }
          if (lost.color && found.color && lost.color.trim().toLowerCase() === found.color.trim().toLowerCase()) {
            traits.push('color');
          }
          if (lost.size && found.size && lost.size.trim().toLowerCase() === found.size.trim().toLowerCase()) {
            traits.push('size');
          }
          if (lost.sex && found.sex && lost.sex.trim().toLowerCase() === found.sex.trim().toLowerCase()) {
            traits.push('sex');
          }

          const distance =
            Math.sqrt((lost.latitude - found.latitude) ** 2 + (lost.longitude - found.longitude) ** 2) * 111;
          const score = Math.min(100, Math.round(traits.length * 20 + Math.max(0, 20 - distance * 4)));

          return {
            id: `${lost.id}:${found.id}`,
            lostReport: this.presentReport(lost),
            foundReport: this.presentReport(found),
            level: score >= 75 ? 'high' : score >= 50 ? 'medium' : 'low',
            score,
            distanceKm: distance,
            matchingTraits: traits,
          };
        }),
    );
  }
}

