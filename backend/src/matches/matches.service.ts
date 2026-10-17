import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class MatchesService {
  constructor(private readonly prisma:PrismaService) {}
  async list(userId:string) { const reports=await this.prisma.petReport.findMany({where:{ownerId:userId,status:'ACTIVE'},include:{photos:true}}); const other=await this.prisma.petReport.findMany({where:{ownerId:{not:userId},status:'ACTIVE'},include:{photos:true}}); return reports.flatMap(lost=>other.filter(found=>found.type!==lost.type && found.species.toLowerCase()===lost.species.toLowerCase()).map(found=>{ const traits=['species']; if(lost.breed.toLowerCase()===found.breed.toLowerCase()) traits.push('breed'); if(lost.color.toLowerCase()===found.color.toLowerCase()) traits.push('color'); const distance=Math.sqrt((lost.latitude-found.latitude)**2+(lost.longitude-found.longitude)**2)*111; const score=Math.min(100, traits.length*25 + Math.max(0,25-distance*5)); return { id:`${lost.id}:${found.id}`, lostReport:{...lost,type:lost.type.toLowerCase()}, foundReport:{...found,type:found.type.toLowerCase()}, level:score>=75?'high':score>=50?'medium':'low', score, distanceKm:distance, matchingTraits:traits }; })); }
}
