-- AlterTable
ALTER TABLE "ServiceListing" ADD COLUMN     "assignedManagerId" TEXT;

-- AddForeignKey
ALTER TABLE "ServiceListing" ADD CONSTRAINT "ServiceListing_assignedManagerId_fkey" FOREIGN KEY ("assignedManagerId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
