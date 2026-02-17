-- CreateEnum
CREATE TYPE "NodalOfficerStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED');

-- CreateEnum
CREATE TYPE "RecommendationStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- AlterEnum
ALTER TYPE "UserRole" ADD VALUE 'NODAL_OFFICER';

-- CreateTable
CREATE TABLE "NodalOfficerAssignment" (
    "id" TEXT NOT NULL,
    "officerId" TEXT NOT NULL,
    "area" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "address" TEXT,
    "pincode" TEXT,
    "region" TEXT,
    "status" "NodalOfficerStatus" NOT NULL DEFAULT 'ACTIVE',
    "notes" TEXT,
    "assignedBy" TEXT,
    "assignedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "NodalOfficerAssignment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "NodalOfficerRecommendation" (
    "id" TEXT NOT NULL,
    "officerId" TEXT NOT NULL,
    "managerId" TEXT NOT NULL,
    "area" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "address" TEXT,
    "pincode" TEXT,
    "region" TEXT,
    "reason" TEXT,
    "status" "RecommendationStatus" NOT NULL DEFAULT 'PENDING',
    "notes" TEXT,
    "reviewedBy" TEXT,
    "reviewedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "NodalOfficerRecommendation_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "NodalOfficerAssignment_location_pincode_idx" ON "NodalOfficerAssignment"("location", "pincode");

-- CreateIndex
CREATE INDEX "NodalOfficerAssignment_status_idx" ON "NodalOfficerAssignment"("status");

-- CreateIndex
CREATE UNIQUE INDEX "NodalOfficerAssignment_officerId_area_location_key" ON "NodalOfficerAssignment"("officerId", "area", "location");

-- CreateIndex
CREATE INDEX "NodalOfficerRecommendation_managerId_idx" ON "NodalOfficerRecommendation"("managerId");

-- CreateIndex
CREATE INDEX "NodalOfficerRecommendation_status_idx" ON "NodalOfficerRecommendation"("status");

-- CreateIndex
CREATE INDEX "NodalOfficerRecommendation_location_area_idx" ON "NodalOfficerRecommendation"("location", "area");

-- AddForeignKey
ALTER TABLE "NodalOfficerAssignment" ADD CONSTRAINT "NodalOfficerAssignment_officerId_fkey" FOREIGN KEY ("officerId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "NodalOfficerRecommendation" ADD CONSTRAINT "NodalOfficerRecommendation_officerId_fkey" FOREIGN KEY ("officerId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "NodalOfficerRecommendation" ADD CONSTRAINT "NodalOfficerRecommendation_managerId_fkey" FOREIGN KEY ("managerId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
