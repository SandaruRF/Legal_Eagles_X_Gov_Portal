# Gov Portal Admin Dashboard

<div align="center">




**Modern Government Services Administrative Dashboard**

[🌐 Live Dashboard](https://anuhasip-gov-portal-admin-dashboard.hf.space/) -  [🚀 Backend API](https://anuhasip-gov-portal-backend.hf.space/docs#) -  [🐛 Issues](https://github.com/SandaruRF/Gov-Portal/issues)

</div>

***

## Overview

React-based administrative dashboard for government officials to manage services, appointments, users, and analytics. Provides comprehensive tools for service configuration, citizen management, and system monitoring.

## ✨ Key Features

- **📊 Analytics Dashboard**: Real-time insights, usage statistics, and performance metrics
- **⚙️ Service Management**: Create, update, and configure government services and forms
- **👥 User Management**: Oversee citizen accounts, KYC verifications, and admin roles
- **📅 Appointment Management**: Handle scheduling, confirmations, and citizen appointments
- **📈 Reports \& Analytics**: Generate detailed reports and system usage analytics
- **🔐 Role-based Access**: Secure authentication with granular permission controls


## 🚀 Quick Start

### Access Live Dashboard

```bash
# Visit the deployed dashboard
https://anuhasip-gov-portal-admin-dashboard.hf.space/
```


### Run from Source

```bash
# Clone repository
git clone https://github.com/SandaruRF/Gov-Portal.git
cd Gov-Portal/frontend/web

# Install dependencies
npm install

# Start development server
npm start
```


## 🗂️ Project Structure

```
web/
├── public/                     # Static assets
│   ├── favicon.ico            # App icon
│   ├── gov-portal-logo.png    # Gov Portal logo
│   ├── index.html             # Main HTML template
│   └── manifest.json          # PWA manifest
├── src/                       # Source code
│   ├── components/            # Reusable UI components
│   ├── config/                # Configuration files
│   ├── contexts/              # React context providers
│   ├── images/                # Image assets
│   ├── services/              # API service integrations
│   ├── styles/                # CSS styling
│   ├── App.js                 # Main App component
│   └── index.js               # React entry point
├── Dockerfile                 # Docker configuration
├── nginx.conf                 # Nginx server config
├── package.json               # Dependencies & scripts
└── README.md                  # Documentation
```


## 📋 Prerequisites

- **Node.js 16+** ([Download Node.js](https://nodejs.org/))
- **npm** or **yarn** package manager
- **Modern web browser** (Chrome, Firefox, Safari, Edge)


## 🛠️ Development

```bash
# Install dependencies
npm install

# Start development server
npm start                      # Runs on http://localhost:3000

# Build for production
npm run build

# Run tests
npm test

# Deploy with Docker
docker build -t gov-portal-dashboard .
docker run -p 3000:80 gov-portal-dashboard
```


## ⚙️ Environment Configuration

```bash
# Create environment file
cp .env.example .env

# Edit with your API endpoints
REACT_APP_API_BASE_URL=https://your-backend-api.com
REACT_APP_ENVIRONMENT=production
```


## 🧪 Available Scripts

- `npm start` - Start development server
- `npm run build` - Build for production
- `npm test` - Run test suite
- `npm run eject` - Eject from Create React App


## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/admin-feature`)
3. Commit your changes (`git commit -m 'Add admin feature'`)
4. Push to branch (`git push origin feature/admin-feature`)
5. Open a Pull Request

***

<div align="center">

**⭐ Star this repository if you find it helpful!**

*Last Updated: August 2025 | Version 1.0.0*

</div>
<div align="center">⁂</div>

