# Gov Portal

<div align="center">


**AI-Powered Government Services Platform for Sri Lanka**

*Simplifying citizen-government interactions through intelligent assistance and digital transformation*

[🚀 Live Demo](https://anuhasip-gov-portal-admin-dashboard.hf.space/) -  [📱 Download APK](https://google.com) -  [📖 API Docs](https://anuhasip-gov-portal-backend.hf.space/docs#) -  [🐛 Report Bug](https://github.com/SandaruRF/Gov-Portal/issues)

</div>

***

## 📋 Table of Contents

1. [Overview](#overview)
2. [✨ Key Features](#-key-features)
3. [🛠️ Technology Stack](#%EF%B8%8F-technology-stack)
4. [📱 Screenshots](#-screenshots)
5. [🚀 Quick Start](#-quick-start)
6. [🏗️ Installation](#%EF%B8%8F-installation)
7. [💻 Usage](#-usage)
8. [🏛️ Project Structure](#%EF%B8%8F-project-structure)
9. [🌐 Deployment](#-deployment)
10. [📚 API Documentation](#-api-documentation)
11. [🤝 Contributing](#-contributing)
12. [📄 License](#-license)
13. [👨💻 Author](#-author)

***

## Overview

**Gov Portal** is a comprehensive, AI-powered government services platform designed to revolutionize how citizens in Sri Lanka interact with public services. By combining intelligent assistance, secure digital identity management, and streamlined administrative workflows, Gov Portal eliminates traditional bureaucratic barriers and creates a seamless digital experience for both citizens and government officials.

### 🎯 Mission

To reduce waiting times, eliminate service uncertainty, and provide universal access to government services through modern technology while maintaining the highest standards of security and accessibility.

***

## ✨ Key Features

### 🤖 **AI-Powered Assistant**

- **Intelligent Chatbot**: Get instant, accurate answers about any government service
- **Smart Suggestions**: Real-time typing assistance based on frequently asked questions
- **Context-Aware Guidance**: Step-by-step assistance for form filling and service navigation
- **24/7 Accessibility**: Support available even without user registration


### 📝 **Digital Service Applications**

- **Dynamic Forms**: Complete and submit digital applications for various government services
- **Document Upload**: Secure digital document submission with validation
- **Form Assistance**: AI-guided form completion with real-time help
- **Multi-language Support**: Accessible in Sinhala, Tamil, and English


### 📅 **Smart Appointment System**

- **Unified Booking**: Schedule appointments across all government departments
- **Interactive Calendar**: Visual appointment scheduling with availability tracking
- **Automated Notifications**: Email/SMS confirmations, reminders, and updates
- **Flexible Management**: Easy rescheduling and cancellation options


### 🔔 **Intelligent Notifications**

- **Personalized Reminders**: Service renewals, deadlines, and age-based alerts
- **Proactive Notifications**: KYC updates, appointment reminders, and document expiry alerts
- **Multi-channel Delivery**: Push notifications, SMS, and email integration


### 🆔 **Digital Identity Hub**

- **Secure KYC Verification**: Optional enhanced security with digital identity creation
- **Document Vault**: Encrypted storage for important legal documents (NIC, licenses, etc.)
- **QR Code Generation**: Share documents securely with officials without physical copies
- **Privacy Controls**: Full user control over data sharing and access


### 👨💼 **Administrative Excellence**

- **Dynamic Service Management**: Create and update services with custom workflows
- **Real-time Analytics**: Monitor usage trends, performance metrics, and user behavior
- **Advanced Reporting**: Generate insights for resource optimization and planning
- **Role-based Access**: Hierarchical admin management with granular permissions


### 📊 **Data-Driven Insights**

- **Usage Analytics**: Track service demand, peak hours, and bottlenecks
- **Performance Monitoring**: Real-time system health and response time tracking
- **Citizen Feedback**: Integrated rating and review system for continuous improvement
- **Predictive Analytics**: Forecast service demand and optimize resource allocation


### ♿ **Universal Accessibility**

- **No-Registration Access**: Full functionality available without account creation
- **Responsive Design**: Optimized for desktop, tablet, and mobile devices
- **Elderly-Friendly Interface**: Large fonts, simple navigation, and clear instructions
- **Multi-demographic Support**: Designed for drivers, travelers, students, and all citizen groups

***

## 🛠️ Technology Stack

<div align="center">

| **Component** | **Technology** | **Purpose** |
|---------------|----------------|-------------|
| **Backend API** | FastAPI | High-performance, modern Python API framework |
| **Database** | PostgreSQL | Robust, scalable relational database (Supabase hosted) |
| **ORM** | Prisma | Type-safe database client and schema management |
| **Mobile App** | Flutter | Cross-platform native mobile application |
| **Web Dashboard** | React | Modern, responsive administrative interface |
| **Message Queue** |  | Caching and background task processing |
| **AI Integration** | Gemini | Advanced natural language processing |
| **Deployment** | Hugging Face | Containerized deployment and scaling |

</div>


***

## 🚀 Quick Start

### Option 1: Access Deployed Services (Recommended)

- **🌐 Admin Dashboard:** [Open Dashboard](https://anuhasip-gov-portal-admin-dashboard.hf.space/)  
- **📱 Mobile App:** Download the APK from the provided link  
- **📖 API Documentation:** [View Docs](https://anuhasip-gov-portal-backend.hf.space/docs#)


### Option 2: Local Development Setup

```bash
# Clone the repository
git clone https://github.com/SandaruRF/Gov-Portal.git
cd Gov-Portal

# Set up the backend
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt

# Set up the frontend
cd ../admin-dashboard
npm install
npm start
```


***

## 🏗️ Installation

### Prerequisites

- **Python 3.8+** - For backend development
- **Node.js 16+** - For React admin dashboard
- **Flutter SDK** - For mobile app development
- **Docker \& Docker Compose** - For containerized deployment
- **Supabase Account** - For database hosting


### 🔧 Environment Configuration

Create a `.env` file in the project root with the following variables:

```env
# Database Configuration
DATABASE_URL="postgresql://postgres:[PASSWORD]@[HOST]:6543/postgres"
SUPABASE_URL="https://your-supabase-url.supabase.co"
SUPABASE_KEY="your-supabase-anon-key"

# Security Configuration  
SECRET_KEY="your-super-secret-jwt-key-minimum-32-characters"
ALGORITHM="HS256"
ACCESS_TOKEN_EXPIRE_MINUTES=43200

# Redis Configuration (for caching and background tasks)
CELERY_BROKER_URL="redis://redis:6379/0"
CELERY_RESULT_BACKEND="redis://redis:6379/0"

# AI Integration
GEMINI_API_KEY="your-google-gemini-api-key"

# Email Configuration (optional)
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT=587
SMTP_USERNAME="your-email@gmail.com"
SMTP_PASSWORD="your-app-password"
```


### 🐳 Docker Deployment

```bash
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```


### 🔧 Manual Setup

#### Backend Setup

```bash
cd backend

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run database migrations
prisma db push --schema=./app/prisma/schema.prisma

# Start the FastAPI server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```


#### Admin Dashboard Setup

```bash
cd admin-dashboard

# Install dependencies
npm install

# Start development server
npm start

# Build for production
npm run build
```


#### Mobile App Setup

```bash
cd mobile-app

# Get Flutter dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build APK
flutter build apk --release
```


***

## 💻 Usage

### 👤 For Citizens

1. **📱 Download the Mobile App** or visit the web portal
2. **🔍 Browse Services** - Explore available government services by category
3. **🤖 Ask the AI Assistant** - Get instant answers to any government-related questions
4. **📝 Fill Applications** - Complete forms with AI guidance and document upload
5. **📅 Book Appointments** - Schedule visits to government offices
6. **🔔 Receive Notifications** - Get reminders and updates about your services
7. **🆔 Optional KYC** - Create a digital identity for enhanced features

### 👨💼 For Government Officials

1. **🔐 Admin Login** - Access the secure administrative dashboard
2. **📊 Monitor Analytics** - View real-time service usage and performance metrics
3. **⚙️ Manage Services** - Create, update, and configure government services
4. **👥 User Management** - Oversee citizen accounts and KYC verifications
5. **📅 Appointment Management** - Handle scheduling and citizen appointments
6. **📈 Generate Reports** - Create detailed analytics and usage reports

***

## 🏛️ Project Structure

```
gov-portal/
├── 🔧 backend/                     # FastAPI Backend
│   ├── app/
│   │   ├── core/                   # Core configurations
│   │   ├── db/                     # Database operations
│   │   │   ├── admin/              # Admin CRUD operations
│   │   │   └── citizen/            # Citizen CRUD operations
│   │   ├── prisma/                 # Database schema & migrations
│   │   ├── routes/                 # API endpoints
│   │   │   ├── admin/              # Admin API routes
│   │   │   └── citizen/            # Citizen API routes
│   │   ├── schemas/                # Pydantic data models
│   │   ├── services/               # Business logic layer
│   │   └── main.py                 # FastAPI application entry
│   ├── venv/                       # Python virtual environment
│   ├── .env                        # Environment variables
│   ├── Dockerfile                  # Container configuration
│   └── requirements.txt            # Python dependencies
├── 🌐 admin-dashboard/             # React Admin Interface
│   ├── public/                     # Static assets
│   ├── src/
│   │   ├── components/             # Reusable UI components
│   │   ├── pages/                  # Application pages
│   │   ├── contexts/               # React context providers
│   │   ├── services/               # API integration
│   │   └── styles/                 # CSS and styling
│   ├── package.json                # Node.js dependencies
│   └── Dockerfile                  # Container configuration
├── 📱 mobile-app/                  # Flutter Mobile App
│   ├── lib/
│   │   ├── models/                 # Data models
│   │   ├── screens/                # UI screens
│   │   ├── services/               # API services
│   │   ├── widgets/                # Custom widgets
│   │   └── main.dart               # App entry point
│   ├── android/                    # Android configuration
│   ├── ios/                        # iOS configuration
│   └── pubspec.yaml                # Flutter dependencies
├── 🐳 docker-compose.yml           # Multi-container orchestration
├── 📚 docs/                        # Documentation
└── 📋 README.md                    # Project documentation
```


***

## 🌐 Deployment

### Live Services

| **Service** | **Status** | **URL** | **Purpose** |
| :-- | :-- | :-- | :-- |
| 🔧 **Backend API** |  | [HuggingFace Space](https://anuhasip-gov-portal-backend.hf.space/docs#) | Core API services and documentation |
| 🌐 **Admin Dashboard** |  | [HuggingFace Space](https://anuhasip-gov-portal-admin-dashboard.hf.space/) | Administrative interface |
| 📱 **Mobile App** |  | [Download APK](https://google.com) | Citizen mobile application |

### 📊 Monitoring \& Logs

- **Backend Logs**: [View Container Logs](https://huggingface.co/spaces/anuhasip/gov-portal-backend?logs=container)
- **Dashboard Logs**: [View Container Logs](https://huggingface.co/spaces/anuhasip/gov-portal-admin-dashboard?logs=container)


### 🚀 Deploy Your Own Instance

```bash
# Clone and configure
git clone https://github.com/SandaruRF/Gov-Portal.git
cd Gov-Portal

# Configure environment
cp .env.example .env
# Edit .env with your credentials

# Deploy with Docker
docker-compose up -d

# Or deploy to cloud platforms
# (Detailed cloud deployment guides available in /docs)
```


***

## 📚 API Documentation

### 🔗 Interactive API Explorer

- **Swagger UI**: [https://anuhasip-gov-portal-backend.hf.space/docs\#](https://anuhasip-gov-portal-backend.hf.space/docs#)
- **ReDoc**: [https://anuhasip-gov-portal-backend.hf.space/redoc](https://anuhasip-gov-portal-backend.hf.space/redoc)

***

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### 🐛 Report Issues

- Use our [Issue Tracker](https://github.com/SandaruRF/Gov-Portal/issues)
- Provide detailed reproduction steps
- Include screenshots for UI issues


### 💡 Suggest Features

- Open a [Feature Request](https://github.com/SandaruRF/Gov-Portal/issues/new?template=feature_request.md)
- Explain the use case and benefits
- Consider implementation complexity


### 📝 Development Guidelines

- Follow existing code style and conventions
- Write comprehensive tests for new features
- Update documentation for any API changes
- Ensure all tests pass before submitting PR
- Keep commits focused and atomic

***

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Sandaru Fernando

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```


***

## 👨💻 Authors

<div align="center">

### **Development Team**

- **Sandaru Fernando**  
- **Anuhas Paranavithana**  
- **Nadil Siriwardhana**  
- **Roshana Helapalla** 
- **Seniru Epasinghe** 
- **Udara Wickramasinghe**   
- **Shihara Fernando**  
- **Sathsara Jayalath** 
- **Savindu Kumarasekara** 

*"Bridging the gap between citizens and government through innovative technology"*

</div>

***

<div align="center">

### 🙏 **Thank You for Your Interest in Gov Portal!**

*Together, we're building a more efficient, accessible, and transparent government service ecosystem for Sri Lanka.*

**⭐ Star this repository if you find it helpful!**

***

*Last Updated: January 2024 | Version 1.0.0*

</div>

<div style="text-align: center">⁂</div>

