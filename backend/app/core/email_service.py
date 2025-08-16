# backend/app/core/email_service.py
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.core.config import settings
import logging
import datetime

logger = logging.getLogger(__name__)


async def send_notification_email(
    email: str,
    subject: str,
    message: str,
    notification_type: str,
    appointment=None,
    document=None
):
    """Send email notification with type-specific templates"""
    if not settings.EMAIL_ENABLED:
        logger.info("Email notifications are disabled in settings")
        return

    try:
        # Use configured credentials
        sender_email = settings.EMAIL_FROM
        sender_password = settings.EMAIL_APP_PASSWORD

        msg = MIMEMultipart()
        msg['From'] = sender_email
        msg['To'] = email
        msg['Subject'] = subject

        if notification_type == "DocumentExpiry":
            body = generate_document_expiry_template(document, message)
        elif notification_type == "AppointmentStatusChange" and appointment:
            body = generate_status_change_template(appointment, message)
        else:
            body = generate_general_template(subject, message)

        msg.attach(MIMEText(body, 'html'))

        with smtplib.SMTP_SSL(settings.SMTP_SERVER, settings.SMTP_PORT) as server:
            server.login(sender_email, sender_password)
            server.send_message(msg)
            logger.info(f"Email notification sent to {email}")

    except Exception as e:
        logger.error(f"Failed to send email to {email}: {str(e)}")


# -------------------------------------------------------------------
# Common Base Template
# -------------------------------------------------------------------
def generate_base_template(title: str, content: str) -> str:
    """Reusable HTML email template with logo, banner, and brand colors"""
    return f"""
    <html>
    <body style="margin:0; padding:0; font-family: Arial, sans-serif; background-color:#f9f9f9;">
        <div style="max-width: 650px; margin: 20px auto; background:#ffffff; border-radius:10px; overflow:hidden; box-shadow:0 4px 10px rgba(0,0,0,0.1);">
            
            <!-- Banner -->
            <div style="background: linear-gradient(90deg, #FF5B00, #FFC107, #8C1F28); padding:20px; text-align:center;">
                <img src="{settings.FRONTEND_URL}/static/logo.png" alt="Gov-Portal" style="height:50px; margin-bottom:10px;">
                <h1 style="color:#fff; margin:0; font-size:22px;">{title}</h1>
            </div>

            <!-- Body -->
            <div style="padding:25px; color:#333; line-height:1.6;">
                {content}
            </div>

            <!-- Footer -->
            <div style="background-color:#f4f4f4; padding:15px; text-align:center; font-size:12px; color:#555;">
                <p>Need help? <a href="{settings.FRONTEND_URL}/support" style="color:#FF5B00; text-decoration:none;">Contact support</a></p>
                <p>© {datetime.datetime.now().year} Gov-Portal. All rights reserved.</p>
            </div>
        </div>
    </body>
    </html>
    """


# -------------------------------------------------------------------
# Appointment Notification Template
# -------------------------------------------------------------------
def generate_status_change_template(appointment, message: str) -> str:
    content = f"""
        <h2 style="color:#279541;">Appointment Update</h2>
        <p><strong>Service:</strong> {appointment.service.name}</p>
        <p><strong>Date/Time:</strong> {appointment.appointment_datetime.strftime('%Y-%m-%d %H:%M')}</p>
        <p><strong>Status:</strong> 
            <span style="color:{get_status_color(appointment.status)}">{appointment.status}</span>
        </p>
        <p>{message}</p>
    """
    return generate_base_template("Gov-Portal Appointment Update 🚀", content)


# -------------------------------------------------------------------
# Document Expiry Template
# -------------------------------------------------------------------
def generate_document_expiry_template(document, message: str) -> str:
    content = f"""
        <h2 style="color:#8C1F28;">Document Expiry Notice</h2>
        <p><strong>Document Type:</strong> {document.document_type}</p>
        <p><strong>Expiry Date:</strong> <span style="color:#FF5B00;">{document.expiry_date.strftime('%Y-%m-%d')}</span></p>
        <p><strong>Days Remaining:</strong> {(document.expiry_date - datetime.datetime.now()).days}</p>
        <p>{message}</p>
        <a href="{settings.FRONTEND_URL}/documents/renew/{document.document_id}" 
           style="display:inline-block; background-color:#279541; color:white; padding:12px 20px; text-decoration:none; border-radius:6px; margin-top:15px;">
            Renew Document
        </a>
    """
    return generate_base_template("Gov-Portal Document Expiry ⏰", content)


# -------------------------------------------------------------------
# General Notification Template
# -------------------------------------------------------------------
def generate_general_template(subject: str, message: str) -> str:
    content = f"""
        <h2 style="color:#FF5B00;">{subject}</h2>
        <p>{message}</p>
        <p><em>Please log in to your account for more details.</em></p>
    """
    return generate_base_template("Gov-Portal Notification 📩", content)


# -------------------------------------------------------------------
# Status Colors
# -------------------------------------------------------------------
def get_status_color(status: str) -> str:
    """Return color based on appointment status"""
    colors = {
        "Booked": "#3498db",      # Blue
        "Confirmed": "#2ecc71",   # Green
        "Completed": "#27ae60",   # Dark Green
        "Cancelled": "#e74c3c",   # Red
    }
    return colors.get(status, "#7f8c8d")  # Default gray
