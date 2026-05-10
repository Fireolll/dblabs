-- CreateEnum
CREATE TYPE "appointment_status" AS ENUM ('заплановано', 'закінчено', 'відмінено', 'в процесі');

-- CreateTable
CREATE TABLE "appointment" (
    "appointment_id" SERIAL NOT NULL,
    "patient_id" INTEGER NOT NULL,
    "doctor_id" INTEGER NOT NULL,
    "reason" TEXT NOT NULL,
    "status" "appointment_status" NOT NULL,
    "start_time" TIMESTAMP(6) NOT NULL,
    "end_time" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "appointment_pkey" PRIMARY KEY ("appointment_id")
);

-- CreateTable
CREATE TABLE "city" (
    "city_id" SERIAL NOT NULL,
    "city_name" VARCHAR(20) NOT NULL,

    CONSTRAINT "city_pkey" PRIMARY KEY ("city_id")
);

-- CreateTable
CREATE TABLE "department" (
    "department_id" INTEGER NOT NULL,
    "dep_name" VARCHAR(20) NOT NULL,
    "floor" SMALLINT NOT NULL,

    CONSTRAINT "department_pkey" PRIMARY KEY ("department_id")
);

-- CreateTable
CREATE TABLE "doctor" (
    "doctor_id" SERIAL NOT NULL,
    "spec_id" INTEGER NOT NULL,
    "dep_id" INTEGER NOT NULL,
    "first_name" VARCHAR(15) NOT NULL,
    "last_name" VARCHAR(15) NOT NULL,
    "email" VARCHAR(30) NOT NULL,
    "phone" VARCHAR(13) NOT NULL,

    CONSTRAINT "doctor_pkey" PRIMARY KEY ("doctor_id")
);

-- CreateTable
CREATE TABLE "doctor_specialization" (
    "spec_id" INTEGER NOT NULL,
    "spec_name" VARCHAR(28) NOT NULL,
    "description" TEXT,

    CONSTRAINT "doctor_specialization_pkey" PRIMARY KEY ("spec_id")
);

-- CreateTable
CREATE TABLE "manufacturer" (
    "manufacturer_id" SERIAL NOT NULL,
    "manuf_name" VARCHAR(30) NOT NULL,

    CONSTRAINT "manufacturer_pkey" PRIMARY KEY ("manufacturer_id")
);

-- CreateTable
CREATE TABLE "medication" (
    "medication_id" INTEGER NOT NULL,
    "med_name" VARCHAR(30) NOT NULL,
    "manufacturer_id" INTEGER NOT NULL,

    CONSTRAINT "medication_pkey" PRIMARY KEY ("medication_id")
);

-- CreateTable
CREATE TABLE "medication_restriction" (
    "restriction_id" SERIAL NOT NULL,
    "medication_id" INTEGER NOT NULL,
    "restriction_description" TEXT NOT NULL,

    CONSTRAINT "medication_restriction_pkey" PRIMARY KEY ("restriction_id")
);

-- CreateTable
CREATE TABLE "medication_side_effect" (
    "side_effect_id" SERIAL NOT NULL,
    "medication_id" INTEGER NOT NULL,
    "effect_description" TEXT NOT NULL,

    CONSTRAINT "medication_side_effect_pkey" PRIMARY KEY ("side_effect_id")
);

-- CreateTable
CREATE TABLE "patient" (
    "patient_id" SERIAL NOT NULL,
    "first_name" VARCHAR(15) NOT NULL,
    "last_name" VARCHAR(15) NOT NULL,
    "date_of_birth" DATE NOT NULL,
    "phone" VARCHAR(13) NOT NULL,
    "email" VARCHAR(30),
    "city_id" INTEGER NOT NULL,
    "street" VARCHAR(25) NOT NULL,
    "building" VARCHAR(4) NOT NULL,

    CONSTRAINT "patient_pkey" PRIMARY KEY ("patient_id")
);

-- CreateTable
CREATE TABLE "prescription" (
    "prescription_id" SERIAL NOT NULL,
    "appointment_id" INTEGER NOT NULL,
    "notes" TEXT,

    CONSTRAINT "prescription_pkey" PRIMARY KEY ("prescription_id")
);

-- CreateTable
CREATE TABLE "prescription_item" (
    "item_id" SERIAL NOT NULL,
    "prescription_id" INTEGER NOT NULL,
    "medication_id" INTEGER NOT NULL,
    "dosage" VARCHAR(20) NOT NULL,
    "instructions" TEXT NOT NULL,

    CONSTRAINT "prescription_item_pkey" PRIMARY KEY ("item_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "appointment_doctor_id_start_time_key" ON "appointment"("doctor_id", "start_time");

-- CreateIndex
CREATE UNIQUE INDEX "city_city_name_key" ON "city"("city_name");

-- CreateIndex
CREATE UNIQUE INDEX "manufacturer_manuf_name_key" ON "manufacturer"("manuf_name");

-- CreateIndex
CREATE UNIQUE INDEX "prescription_appointment_id_key" ON "prescription"("appointment_id");

-- AddForeignKey
ALTER TABLE "appointment" ADD CONSTRAINT "appointment_doctor_id_fkey" FOREIGN KEY ("doctor_id") REFERENCES "doctor"("doctor_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "appointment" ADD CONSTRAINT "appointment_patient_id_fkey" FOREIGN KEY ("patient_id") REFERENCES "patient"("patient_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "doctor" ADD CONSTRAINT "doctor_dep_id_fkey" FOREIGN KEY ("dep_id") REFERENCES "department"("department_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "doctor" ADD CONSTRAINT "doctor_spec_id_fkey" FOREIGN KEY ("spec_id") REFERENCES "doctor_specialization"("spec_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "medication" ADD CONSTRAINT "medication_manufacturer_id_fkey" FOREIGN KEY ("manufacturer_id") REFERENCES "manufacturer"("manufacturer_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "medication_restriction" ADD CONSTRAINT "medication_restriction_medication_id_fkey" FOREIGN KEY ("medication_id") REFERENCES "medication"("medication_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "medication_side_effect" ADD CONSTRAINT "medication_side_effect_medication_id_fkey" FOREIGN KEY ("medication_id") REFERENCES "medication"("medication_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "patient" ADD CONSTRAINT "patient_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "city"("city_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "prescription" ADD CONSTRAINT "prescription_appointment_id_fkey" FOREIGN KEY ("appointment_id") REFERENCES "appointment"("appointment_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "prescription_item" ADD CONSTRAINT "prescription_item_medication_id_fkey" FOREIGN KEY ("medication_id") REFERENCES "medication"("medication_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "prescription_item" ADD CONSTRAINT "prescription_item_prescription_id_fkey" FOREIGN KEY ("prescription_id") REFERENCES "prescription"("prescription_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
