-- AlterTable
ALTER TABLE "appointment" ADD COLUMN     "treatment_id" INTEGER;

-- CreateTable
CREATE TABLE "treatment_plan" (
    "treatment_id" SERIAL NOT NULL,
    "title" VARCHAR(100) NOT NULL,
    "description" TEXT NOT NULL,
    "duration_days" INTEGER,

    CONSTRAINT "treatment_plan_pkey" PRIMARY KEY ("treatment_id")
);

-- AddForeignKey
ALTER TABLE "appointment" ADD CONSTRAINT "appointment_treatment_id_fkey" FOREIGN KEY ("treatment_id") REFERENCES "treatment_plan"("treatment_id") ON DELETE SET NULL ON UPDATE CASCADE;
