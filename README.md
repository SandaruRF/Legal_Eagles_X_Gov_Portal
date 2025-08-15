# **Gov-Portal: Centralized Government Services Portal**

**Gov-Portal** is a modern, centralized portal designed to streamline how citizens in Sri Lanka access government services. The project aims to reduce waiting times, eliminate uncertainty, and provide a seamless digital interface for booking appointments and managing government-related tasks.

## **✨ Key Features**

* **Unified Appointment Booking:** A central directory to browse government departments, select services, and book appointments through an interactive calendar.  
* **Citizen Dashboard:** A secure, personal space for citizens to manage their appointments, upload required documents in advance, and maintain a digital vault for their IDs.  
* **Government Officer Interface:** A secure dashboard for officials to manage schedules, review pre-submitted documents, and communicate with citizens.  
* **Automated Notifications:** An automated system (Email/SMS) for appointment confirmations, reminders, and status updates.  
* **Analytics Dashboard:** Data visualization for authorities to monitor key metrics like peak hours, departmental load, and no-show rates to optimize resource allocation.  
* **Integrated Feedback System:** Allows citizens to rate and review their experience, promoting accountability and continuous improvement.

## **🛠️ Technology Stack**

This project is built with a modern, scalable, and robust technology stack:

* **Backend:** FastAPI  
* **Database:** PostgreSQL (hosted on Supabase)  
* **ORM:** Prisma Client for Python  
* **Mobile App (Citizen):** Flutter
* **Web App (Admin/Officer):** React

## **Prerequisites**

Before you begin, ensure you have the following installed on your system:

* [Docker](https://docs.docker.com/get-docker/)  
* [Docker Compose](https://docs.docker.com/compose/install/) (usually included with Docker Desktop)

## **Environment Variables (Critical for Security)**

This project uses sensitive information (API keys, database passwords, etc.). To keep these secrets secure and out of version control, you must create a .env file in the root directory of the project.

1. **Create the file:**  
   touch .env

2. **Add the following variables to your .env file**, replacing the placeholder values with your actual credentials:  
   \# .env

   \# Backend Environment Variables  
   DATABASE\_URL="database\_url\_from\_supabase"  
   SUPABASE\_URL="https\_your\_supabase\_url"  
   SUPABASE\_KEY="your\_supabase\_key"  
   SECRET\_KEY="your\_very\_secret\_key"  
   ALGORITHM="HS256"  
   ACCESS\_TOKEN\_EXPIRE\_MINUTES=43200  
   CELERY\_BROKER\_URL="redis://redis:6379/0"  
   CELERY\_RESULT\_BACKEND="redis://redis:6379/0"  
   GEMINI\_API\_KEY="your\_gemini\_api\_key"

## **Deployment**

This project's backend, admin dashboard are published on huggingface. also, you can access the mobile apk.

1. **Backend**
   * [Huggingface Logs](https://huggingface.co/spaces/anuhasip/gov-portal-backend?logs=container)
   * [Swagger API Docs](https://anuhasip-gov-portal-backend.hf.space/docs#)

2. **Admin Dashboard**
    * [Huggingface Logs](https://huggingface.co/spaces/anuhasip/gov-portal-admin-dashboard?logs=container)
    * [View Admin Dashboard](https://anuhasip-gov-portal-admin-dashboard.hf.space/)

3. **Mobile App (Citizen)**
    * [APK File](https://google.com)