import { PrismaClient, UserRole } from '@prisma/client';
import argon2 from 'argon2';
const prisma = new PrismaClient();
async function main() {
    const passwordHash = await argon2.hash('Pass@1234');
    const admin = await prisma.user.upsert({
        where: { email: 'admin@example.com' },
        update: {},
        create: {
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
    console.log('Seeded admin user', admin.email);
    // Create a test verification provider
    const providerUser = await prisma.user.upsert({
        where: { email: 'provider@example.com' },
        update: {},
        create: {
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
    const provider = await prisma.serviceProvider.upsert({
        where: { userId: providerUser.id },
        update: {
            status: 'APPROVED',
        },
        create: {
            userId: providerUser.id,
            status: 'APPROVED',
            kycDocumentUrl: 'https://example.com/kyc.pdf',
            pricingDetails: 'Standard verification rates',
        },
    });
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
