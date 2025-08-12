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

## **🏗️ Project Structure**

The backend is organized into modules to separate concerns, making the codebase clean and maintainable.

backend/  
│  
├── app/  
│   ├── core/               \# Core application logic (database, security)  
│   ├── db/                 \# CRUD (database interaction) functions  
│   │   ├── admin/  
│   │   └── citizen/  
│   ├── prisma/             \# Prisma schema and migrations  
│   ├── routes/             \# API endpoint definitions  
│   │   ├── admin/  
│   │   └── citizen/  
│   ├── schemas/            \# Pydantic models for data validation  
│   │   ├── admin/  
│   │   └── citizen/  
│   ├── services/           \# Business logic (e.g., sending notifications)  
│   │   ├── admin/  
│   │   └── citizen/  
│   └── main.py             \# Main FastAPI application entry point  
│  
├── venv/                   \# Virtual environment directory  
├── .env                    \# Environment variables  
├── .gitignore              \# Git ignore file  
├── Dockerfile              \# Docker configuration  
├── README.md               \# This file  
└── requirements.txt        \# Python dependencies

## **🚀 Getting Started**

Follow these instructions to set up and run the backend server on your local machine.

### **Prerequisites**

* Python 3.8+  
* A Supabase account

### **1\. Clone the Repository**

git clone https://github.com/SandaruRF/Gov-Portal  
cd backend

### **2\. Set Up Environment Variables**

1. Navigate to your Supabase project's **Settings \> Database**.  
2. Under "Connection string", select the **Transaction pooler** tab and copy the URI.  
3. Create a file named .env in the backend directory.  
4. Paste the connection string into the .env file:  
   \# backend/.env  
   DATABASE\_URL="postgresql://postgres:\[YOUR-PASSWORD\]@\[YOUR-HOST\]:6543/postgres"

### **3\. Create and Activate Virtual Environment**

It's crucial to use a virtual environment to keep project dependencies isolated.

\# Create a virtual environment named 'venv'  
python \-m venv venv

\# Activate the virtual environment  
\# On Windows:  
venv\\Scripts\\activate

\# On macOS/Linux:  
source venv/bin/activate

Your terminal prompt should now start with (venv), indicating the environment is active.

### **4\. Install Dependencies**

With your virtual environment active, install the required packages.
 
pip install \-r requirements.txt

### **5\. Create Database Migration**

This command creates a migration file based on your schema.prisma changes and applies it to the database. This is the standard way to manage schema changes during development.

*(Note: The \--schema flag points to the location of the schema file)*
prisma generate \--schema=./app/prisma/schema.prisma

*(Note: No need to run the below command)*
prisma db push \--schema=./app/prisma/schema.prisma

This command will create a migration file and apply it to the database. For subsequent changes, you can give the migration a more descriptive name (e.g., add\_feedback\_model).

### **6\. Run the Application**

Use Uvicorn, to run the FastAPI application.

uvicorn app.main:app \--reload

The \--reload flag will automatically restart the server whenever you make changes to the code.

## **📚 API Documentation**

Once the server is running, you can access the interactive API documentation (powered by Swagger UI) at:

http://127.0.0.1:8000/docs

This interface allows you to view and test all the available API endpoints directly from your browser.