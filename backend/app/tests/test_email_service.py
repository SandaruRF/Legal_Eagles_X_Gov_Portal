import asyncio
from datetime import datetime, timedelta
from app.core.email_service import send_notification_email
from app.core.config import settings
from types import SimpleNamespace
from app.core.config import settings

async def main():
    # ✅ Make sure email sending is enabled
    settings.EMAIL_ENABLED = True
    settings.EMAIL_FROM = "shiharaf8@gmail.com"
    settings.EMAIL_APP_PASSWORD = "incx jkcr sspk gqdt"  # For Gmail, use App Passwords
    settings.SMTP_SERVER = "smtp.gmail.com"
    settings.SMTP_PORT = 465
    settings.FRONTEND_URL = "https://yourfrontendurl.com"

    # 1️⃣ Test General Notification
    await send_notification_email(
        email="shiharaf8@gmail.com",
        subject="Test General Notification",
        message="This is a test general notification email.",
        notification_type="General"
    )

    # 2️⃣ Test Appointment Status Change
    appointment = SimpleNamespace(
        service=SimpleNamespace(name="Driver's License Renewal"),
        appointment_datetime=datetime.now() + timedelta(days=2),
        status="Confirmed"
    )
    await send_notification_email(
        email="shiharaf8@gmail.com",
        subject="Test Appointment Status",
        message="Your appointment status has been updated.",
        notification_type="AppointmentStatusChange",
        appointment=appointment
    )

    # 3️⃣ Test Document Expiry
    document = SimpleNamespace(
        document_type="Passport",
        expiry_date=datetime.now() + timedelta(days=15),
        document_id="12345"
    )
    await send_notification_email(
        email="shiharaf8@gmail.com",
        subject="Test Document Expiry",
        message="Your document is about to expire.",
        notification_type="DocumentExpiry",
        appointment=document  # Not needed here
    )

if __name__ == "__main__":
    asyncio.run(main())