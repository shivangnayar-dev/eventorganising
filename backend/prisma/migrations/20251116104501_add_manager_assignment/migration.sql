-- CreateEnum
CREATE TYPE "ManagerAssignmentStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED');

-- CreateTable
CREATE TABLE "ManagerAssignment" (
    "id" TEXT NOT NULL,
    "managerId" TEXT NOT NULL,
    "area" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "address" TEXT,
    "pincode" TEXT,
    "region" TEXT,
    "status" "ManagerAssignmentStatus" NOT NULL DEFAULT 'ACTIVE',
    "notes" TEXT,
    "assignedBy" TEXT,
    "assignedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ManagerAssignment_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ManagerAssignment_managerId_key" ON "ManagerAssignment"("managerId");

-- CreateIndex
CREATE INDEX "ManagerAssignment_location_pincode_idx" ON "ManagerAssignment"("location", "pincode");

-- CreateIndex
CREATE INDEX "ManagerAssignment_status_idx" ON "ManagerAssignment"("status");

-- AddForeignKey
ALTER TABLE "ManagerAssignment" ADD CONSTRAINT "ManagerAssignment_managerId_fkey" FOREIGN KEY ("managerId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
