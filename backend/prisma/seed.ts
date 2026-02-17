import { PrismaClient, UserRole } from '@prisma/client';
import argon2 from 'argon2';

const prisma = new PrismaClient();

async function main() {
  const passwordHash = await argon2.hash('Pass@1234');

  // Check if admin user exists, if not create it
  let admin = await prisma.user.findUnique({
    where: { email: 'admin@example.com' },
    include: { roles: true },
  });

  if (!admin) {
    admin = await prisma.user.create({
      data: {
        email: 'admin@example.com',
        passwordHash,
        fullName: 'System Admin',
        roles: {
          create: [
            { role: UserRole.ADMIN },
            { role: UserRole.MANAGER },
          ],
        },
      },
      include: { roles: true },
    });
  }

  console.log('Seeded admin user', admin.email);

  // Check if provider user exists, if not create it
  let providerUser = await prisma.user.findUnique({
    where: { email: 'provider@example.com' },
    include: { roles: true },
  });

  if (!providerUser) {
    providerUser = await prisma.user.create({
      data: {
        email: 'provider@example.com',
        passwordHash,
        fullName: 'Test Provider',
        roles: {
          create: [
            { role: UserRole.PROVIDER },
          ],
        },
      },
      include: { roles: true },
    });
  }

  // Check if provider exists, if not create it
  let provider = await prisma.serviceProvider.findUnique({
    where: { userId: providerUser.id },
  });

  if (!provider) {
    provider = await prisma.serviceProvider.create({
      data: {
        userId: providerUser.id,
        status: 'APPROVED',
        kycDocumentUrl: 'https://example.com/kyc.pdf',
        pricingDetails: 'Standard verification rates',
      },
    });
  }

  console.log('Seeded test provider', providerUser.email);
}

main()
  .catch((error) => {
    console.error('Seed error', error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

