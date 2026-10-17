import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcryptjs';
const prisma = new PrismaClient();
async function main() { const passwordHash=await bcrypt.hash('PetlinkDemo123!',12); const user=await prisma.user.upsert({where:{email:'demo@petlink.local'},update:{},create:{name:'PetLink Demo',email:'demo@petlink.local',passwordHash}}); await prisma.petReport.create({data:{ownerId:user.id,type:'LOST',name:'Luna',species:'Perro',breed:'Golden Retriever',sex:'Hembra',age:'4 años',size:'Grande',color:'Dorado',description:'Reporte de ejemplo para desarrollo local.',latitude:1.2136,longitude:-77.2811,address:'Pasto',lastSeenAt:new Date()}}); }
main().finally(()=>prisma.$disconnect());
