# Gov Portal

[![Project Logo](https://drive.google.com/file/d/1JW9IfNykGz3o7lca0ahLewNfMZgUbxq0/view)](https://drive.google.com/file/d/1JW9IfNykGz3o7lca0ahLewNfMZgUbxq0/view)

Gov Portal is an AI-powered government services platform designed to simplify and modernize the way citizens interact with public services. It combines intelligent assistance, secure digital identity management, and administrative control to provide a seamless experience for both users and government administrators.

## Table of Contents

1.  [Key Features](#key-features)
2.  [Screenshots](#screenshots)
3.  [Installation](#installation)
4.  [Usage](#usage)
5.  [License](#license)
6.  [Author](#author)

## Key Features

*   AI-Powered Chatbot: Ask questions about any government service and receive instant, accurate answers. Smart suggestions while typing based on frequently asked questions. Context-aware assistance within specific interfaces, such as guiding users through form filling, answering appointment-related queries, or navigating service-specific workflows. Provides support even without sign-up, ensuring accessibility to all users.
*   Registration Forms & Service Applications: Complete and submit digital forms for a wide range of government services. The chatbot assists in filling forms by providing step-by-step guidance and clarifications. Supports digital uploads of required documents, reducing the need for physical paperwork.
*   Appointment Booking & Scheduling: Schedule appointments for services such as passports, license renewals, or other government procedures. Receive confirmations, reminders, and follow-ups for booked appointments. Users can manage, reschedule, or cancel appointments directly through the app.
*   Notification & Reminder System: Personalized reminders for service renewals, deadlines, or age-based alerts (e.g., vaccines, TIN updates, fuel pass renewals). Push notifications for upcoming appointments, KYC status updates, and follow-up actions.
*   Digital Identity & Document Management: Optional sign-up with KYC verification for creating a secure digital identity. Upload and store important legal documents (NIC, licenses, insurance, etc.). Generate secure QR codes to share documents with officials without carrying physical copies.
*   Admin Dashboard & Management: Create, update, and manage government services, including dynamic forms and application workflows. Monitor system usage, generate statistical reports, and perform analysis of service requests. Admin management features to assign roles, manage users, and oversee KYC verifications. Track booking confirmations, send automated notifications and follow-ups to users.
*   Analytics & Insights: Gain insights into service usage trends, user interactions, and overall system performance. Track bottlenecks, optimize services, and improve citizen engagement.
*   Accessibility & Usability: Fully functional even without an account, with optional digital ID features for enhanced convenience. Designed for drivers, travelers, students, and elderly users, ensuring universal accessibility. Provides an intuitive interface that guides users through every step of interacting with government services.

## Screenshots

![Admin Dashboard](https://drive.google.com/file/d/1vZ5AskMJX3wMAP3i6RDKYUlpPeBUK5WX/view?usp=sharing)
*Admin Dashboard*

![Mobile App](https://drive.google.com/file/d/1Rk6zAdCSU7fuYCjE7oOQz_JL1D9k1S-M/view?usp=sharing)
*Mobile App*

## Installation

```
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
   # .env

   # Backend Environment Variables  
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
```

## Usage

```
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
│   ├── core/               # Core application logic (database, security)  
│   ├── db/                 # CRUD (database interaction) functions  
│   │   ├── admin/  
│   │   └── citizen/  
│   ├── prisma/             # Prisma schema and migrations  
│   ├── routes/             # API endpoint definitions  
│   │   ├── admin/  
│   │   └── citizen/  
│   ├── schemas/            # Pydantic models for data validation  
│   │   ├── admin/  
│   │   └── citizen/  
│   ├── services/           # Business logic (e.g., sending notifications)  
│   │   ├── admin/  
│   │   └── citizen/  
│   └── main.py             # Main FastAPI application entry point  
│  
├── venv/                   # Virtual environment directory  
├── .env                    # Environment variables  
├── .gitignore              # Git ignore file  
├── Dockerfile              # Docker configuration  
├── README.md               # This file  
└── requirements.txt        # Python dependencies

## **🚀 Getting Started**

Follow these instructions to set up and run the backend server on your local machine.

### **Prerequisites**

* Python 3.8+  
* A Supabase account

### **1. Clone the Repository**

git clone https://github.com/SandaruRF/Gov-Portal  
cd backend

### **2. Set Up Environment Variables**

1. Navigate to your Supabase project's **Settings > Database**.  
2. Under "Connection string", select the **Transaction pooler** tab and copy the URI.  
3. Create a file named .env in the backend directory.  
4. Paste the connection string into the .env file:  
   # backend/.env  
   DATABASE\_URL="postgresql://postgres:[YOUR-PASSWORD]@[YOUR-HOST]:6543/postgres"

### **3. Create and Activate Virtual Environment**

It's crucial to use a virtual environment to keep project dependencies isolated.

# Create a virtual environment named 'venv'  
python -m venv venv

# Activate the virtual environment  
# On Windows:  
venv\Scripts\activate

# On macOS/Linux:  
source venv/bin/activate

Your terminal prompt should now start with (venv), indicating the environment is active.

### **4. Install Dependencies**

With your virtual environment active, install the required packages.
 
pip install -r requirements.txt

### **5. Create Database Migration**

This command creates a migration file based on your schema.prisma changes and applies it to the database. This is the standard way to manage schema changes during development.

*(Note: The --schema flag points to the location of the schema file)*


*(Note: No need to run the below command)*
prisma db push --schema=./app/prisma/schema.prisma

This command will create a migration file and apply it to the database. For subsequent changes, you can give the migration a more descriptive name (e.g., add\_feedback\_model).

### **6. Run the Application**

Use Uvicorn, to run the FastAPI application.

uvicorn app.main:app --reload

The --reload flag will automatically restart the server whenever you make changes to the code.

## **📚 API Documentation**

Once the server is running, you can access the interactive API documentation (powered by Swagger UI) at:

http://127.0.0.1:8000/docs

This interface allows you to view and test all the available API endpoints directly from your browser.


========================================


# Getting Started with Create React App

This project was bootstrapped with [Create React App](https://github.com/facebook/create-react-app).

## Available Scripts

In the project directory, you can run:

### `npm start`

Runs the app in the development mode.
Open [http://localhost:3000](http://localhost:3000) to view it in your browser.

The page will reload when you make changes.
You may also see any lint errors in the console.

### `npm test`

Launches the test runner in the interactive watch mode.
See the section about [running tests](https://facebook.github.io/create-react-app/docs/running-tests) for more information.

### `npm run build`

Builds the app for production to the `build` folder.
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.
Your app is ready to be deployed!

See the section about [deployment](https://facebook.github.io/create-react-app/docs/deployment) for more information.

### `npm run eject`

**Note: this is a one-way operation. Once you `eject`, you can't go back!**

If you aren't satisfied with the build tool and configuration choices, you can `eject` at any time. This command will remove the single build dependency from your project.

Instead, it will copy all the configuration files and the transitive dependencies (webpack, Babel, ESLint, etc) right into your project so you have full control over them. All of the commands except `eject` will still work, but they will point to the copied scripts so you can tweak them. At this point you're on your own.

You don't have to ever use `eject`. The curated feature set is suitable for small and middle deployments, and you shouldn't feel obligated to use this feature. However we understand that this tool wouldn't be useful if you couldn't customize it when you are ready for it.

## Learn More

You can learn more in the [Create React App documentation](https://facebook.github.io/create-react-app/docs/getting-started).

To learn React, check out the [React documentation](https://reactjs.org/).

### Code Splitting

This section has moved here: [https://facebook.github.io/create-react-app/docs/code-splitting](https://facebook.github.io/create-react-app/docs/code-splitting)

### Analyzing the Bundle Size

This section has moved here: [https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size](https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size)

### Making a Progressive Web App

This section has moved here: [https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app](https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app)

### Advanced Configuration

This section has moved here: [https://facebook.github.io/create-react-app/docs/advanced-configuration](https://facebook.github.io/create-react-app/docs/advanced-configuration)

### Deployment

This section has moved here: [https://facebook.github.io/create-react-app/docs/deployment](https://facebook.github.io/create-react-app/docs/deployment)

### `npm run build` fails to minify

This section has moved here: [https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify](https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify)
```

## License

This project is licensed under the MIT License.

## Author

Sandaru Fernando <sandarurf@gmail.com>
