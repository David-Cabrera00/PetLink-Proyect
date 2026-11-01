const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const users = await prisma.user.findMany({
    select: { id: true, email: true, name: true, createdAt: true }
  });
  console.log('Registered users:', JSON.stringify(users, null, 2));

  const resets = await prisma.passwordReset.findMany({
    orderBy: { createdAt: 'desc' },
    take: 5
  });
  console.log('Recent password resets:', JSON.stringify(resets, null, 2));
}

main().catch(console.error).finally(() => prisma.$disconnect());

