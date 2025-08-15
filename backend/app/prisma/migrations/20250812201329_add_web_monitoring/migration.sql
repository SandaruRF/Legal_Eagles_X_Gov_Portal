-- CreateEnum
CREATE TYPE "public"."KYCStatus" AS ENUM ('Pending', 'Verified', 'Rejected');

-- CreateEnum
CREATE TYPE "public"."VaultDocumentType" AS ENUM ('NIC', 'Passport', 'License', 'BirthCertificate', 'Other');

-- CreateEnum
CREATE TYPE "public"."AdminRole" AS ENUM ('Officer', 'Head');

-- CreateEnum
CREATE TYPE "public"."AppointmentStatus" AS ENUM ('Booked', 'Confirmed', 'Completed', 'Cancelled', 'NoShow');

-- CreateTable
CREATE TABLE "public"."Citizen" (
    "citizen_id" TEXT NOT NULL,
    "full_name" TEXT NOT NULL,
    "nic_no" TEXT NOT NULL,
    "phone_no" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Citizen_pkey" PRIMARY KEY ("citizen_id")
);

-- CreateTable
CREATE TABLE "public"."KYC" (
    "kyc_id" TEXT NOT NULL,
    "nic_front_url" TEXT,
    "nic_back_url" TEXT,
    "selfie_url" TEXT,
    "status" "public"."KYCStatus" NOT NULL DEFAULT 'Pending',
    "verified_at" TIMESTAMP(3),
    "citizen_id" TEXT NOT NULL,
    "verified_by_id" TEXT,

    CONSTRAINT "KYC_pkey" PRIMARY KEY ("kyc_id")
);

-- CreateTable
CREATE TABLE "public"."DigitalVaultDocument" (
    "document_id" TEXT NOT NULL,
    "document_type" "public"."VaultDocumentType" NOT NULL,
    "document_url" TEXT NOT NULL,
    "uploaded_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "citizen_id" TEXT NOT NULL,

    CONSTRAINT "DigitalVaultDocument_pkey" PRIMARY KEY ("document_id")
);

-- CreateTable
CREATE TABLE "public"."Department" (
    "department_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,

    CONSTRAINT "Department_pkey" PRIMARY KEY ("department_id")
);

-- CreateTable
CREATE TABLE "public"."Service" (
    "service_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "required_documents" JSONB,
    "department_id" TEXT NOT NULL,

    CONSTRAINT "Service_pkey" PRIMARY KEY ("service_id")
);

-- CreateTable
CREATE TABLE "public"."Admin" (
    "admin_id" TEXT NOT NULL,
    "full_name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "role" "public"."AdminRole" NOT NULL DEFAULT 'Officer',
    "department_id" TEXT NOT NULL,

    CONSTRAINT "Admin_pkey" PRIMARY KEY ("admin_id")
);

-- CreateTable
CREATE TABLE "public"."Appointment" (
    "appointment_id" TEXT NOT NULL,
    "appointment_datetime" TIMESTAMP(3) NOT NULL,
    "status" "public"."AppointmentStatus" NOT NULL DEFAULT 'Booked',
    "reference_number" TEXT NOT NULL,
    "qr_code_data" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "citizen_id" TEXT NOT NULL,
    "service_id" TEXT NOT NULL,
    "assigned_admin_id" TEXT,

    CONSTRAINT "Appointment_pkey" PRIMARY KEY ("appointment_id")
);

-- CreateTable
CREATE TABLE "public"."AppointmentDocument" (
    "appointment_doc_id" TEXT NOT NULL,
    "document_name" TEXT NOT NULL,
    "document_url" TEXT NOT NULL,
    "uploaded_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "appointment_id" TEXT NOT NULL,

    CONSTRAINT "AppointmentDocument_pkey" PRIMARY KEY ("appointment_doc_id")
);

-- CreateTable
CREATE TABLE "public"."FormTemplate" (
    "form_id" TEXT NOT NULL,
    "form_name" TEXT NOT NULL,
    "template_url" TEXT NOT NULL,
    "service_id" TEXT NOT NULL,

    CONSTRAINT "FormTemplate_pkey" PRIMARY KEY ("form_id")
);

-- CreateTable
CREATE TABLE "public"."FilledForm" (
    "filled_form_id" TEXT NOT NULL,
    "filled_data" JSONB NOT NULL,
    "generated_pdf_url" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "form_id" TEXT NOT NULL,
    "citizen_id" TEXT NOT NULL,

    CONSTRAINT "FilledForm_pkey" PRIMARY KEY ("filled_form_id")
);

-- CreateTable
CREATE TABLE "public"."Feedback" (
    "feedback_id" TEXT NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "submitted_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "appointment_id" TEXT NOT NULL,
    "citizen_id" TEXT NOT NULL,

    CONSTRAINT "Feedback_pkey" PRIMARY KEY ("feedback_id")
);

-- CreateTable
CREATE TABLE "public"."WebPageRecord" (
    "id" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "content_hash" TEXT NOT NULL,
    "last_checked" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_modified" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "content_preview" TEXT,
    "error_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "WebPageRecord_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."ContentChangeLog" (
    "id" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "old_hash" TEXT,
    "new_hash" TEXT NOT NULL,
    "change_type" TEXT NOT NULL,
    "detected_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "web_page_id" TEXT,

    CONSTRAINT "ContentChangeLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Citizen_nic_no_key" ON "public"."Citizen"("nic_no");

-- CreateIndex
CREATE UNIQUE INDEX "Citizen_phone_no_key" ON "public"."Citizen"("phone_no");

-- CreateIndex
CREATE UNIQUE INDEX "Citizen_email_key" ON "public"."Citizen"("email");

-- CreateIndex
CREATE UNIQUE INDEX "KYC_citizen_id_key" ON "public"."KYC"("citizen_id");

-- CreateIndex
CREATE UNIQUE INDEX "Department_name_key" ON "public"."Department"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Admin_email_key" ON "public"."Admin"("email");

-- CreateIndex
CREATE UNIQUE INDEX "Appointment_reference_number_key" ON "public"."Appointment"("reference_number");

-- CreateIndex
CREATE UNIQUE INDEX "Appointment_qr_code_data_key" ON "public"."Appointment"("qr_code_data");

-- CreateIndex
CREATE UNIQUE INDEX "Feedback_appointment_id_key" ON "public"."Feedback"("appointment_id");

-- CreateIndex
CREATE UNIQUE INDEX "WebPageRecord_url_key" ON "public"."WebPageRecord"("url");

-- AddForeignKey
ALTER TABLE "public"."KYC" ADD CONSTRAINT "KYC_citizen_id_fkey" FOREIGN KEY ("citizen_id") REFERENCES "public"."Citizen"("citizen_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."KYC" ADD CONSTRAINT "KYC_verified_by_id_fkey" FOREIGN KEY ("verified_by_id") REFERENCES "public"."Admin"("admin_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."DigitalVaultDocument" ADD CONSTRAINT "DigitalVaultDocument_citizen_id_fkey" FOREIGN KEY ("citizen_id") REFERENCES "public"."Citizen"("citizen_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Service" ADD CONSTRAINT "Service_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "public"."Department"("department_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Admin" ADD CONSTRAINT "Admin_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "public"."Department"("department_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Appointment" ADD CONSTRAINT "Appointment_citizen_id_fkey" FOREIGN KEY ("citizen_id") REFERENCES "public"."Citizen"("citizen_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Appointment" ADD CONSTRAINT "Appointment_service_id_fkey" FOREIGN KEY ("service_id") REFERENCES "public"."Service"("service_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Appointment" ADD CONSTRAINT "Appointment_assigned_admin_id_fkey" FOREIGN KEY ("assigned_admin_id") REFERENCES "public"."Admin"("admin_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."AppointmentDocument" ADD CONSTRAINT "AppointmentDocument_appointment_id_fkey" FOREIGN KEY ("appointment_id") REFERENCES "public"."Appointment"("appointment_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."FormTemplate" ADD CONSTRAINT "FormTemplate_service_id_fkey" FOREIGN KEY ("service_id") REFERENCES "public"."Service"("service_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."FilledForm" ADD CONSTRAINT "FilledForm_form_id_fkey" FOREIGN KEY ("form_id") REFERENCES "public"."FormTemplate"("form_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."FilledForm" ADD CONSTRAINT "FilledForm_citizen_id_fkey" FOREIGN KEY ("citizen_id") REFERENCES "public"."Citizen"("citizen_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Feedback" ADD CONSTRAINT "Feedback_appointment_id_fkey" FOREIGN KEY ("appointment_id") REFERENCES "public"."Appointment"("appointment_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Feedback" ADD CONSTRAINT "Feedback_citizen_id_fkey" FOREIGN KEY ("citizen_id") REFERENCES "public"."Citizen"("citizen_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ContentChangeLog" ADD CONSTRAINT "ContentChangeLog_web_page_id_fkey" FOREIGN KEY ("web_page_id") REFERENCES "public"."WebPageRecord"("id") ON DELETE SET NULL ON UPDATE CASCADE;
