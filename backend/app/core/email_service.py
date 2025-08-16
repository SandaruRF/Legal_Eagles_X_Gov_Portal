# backend/app/core/email_service.py
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.core.config import settings
import logging
import datetime
 

logger = logging.getLogger(_name_)

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

def generate_status_change_template(appointment, message: str) -> str:
    """Generate HTML template for appointment status changes"""
    return f"""
    <html>
    <body style="font-family: Arial, sans-serif; line-height: 1.6;">
        <div style="max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd;">
            <h2 style="color: #2c3e50;">Gov-Portal Appointment Update</h2>
            
            <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
                <p><strong>Service:</strong> {appointment.service.name}</p>
                <p><strong>Date/Time:</strong> {appointment.appointment_datetime.strftime('%Y-%m-%d %H:%M')}</p>
                <p><strong>Status:</strong> <span style="color: {get_status_color(appointment.status)}">{appointment.status}</span></p>
            </div>
            
            <p>{message}</p>
            
            <div style="margin-top: 30px; font-size: 0.9em; color: #7f8c8d;">
                <p>Need help? <a href="{settings.FRONTEND_URL}/support">Contact support</a></p>
                <p>© {datetime.now().year} Gov-Portal. All rights reserved.</p>
            </div>
        </div>
    </body>
    </html>
    """

def generate_general_template(subject: str, message: str) -> str:
    """Default template for other notifications"""
    return f"""
    <html>
    <body>
        <h2>Gov-Portal Notification</h2>
        <p><strong>Subject:</strong> {subject}</p>
        <p><strong>Message:</strong></p>
        <p>{message}</p>
        <hr>
        <p>Please log in to your account for details.</p>
    </body>
    </html>
    """

def get_status_color(status: str) -> str:
    """Return color based on appointment status"""
    colors = {
        "Booked": "#3498db",      # Blue
        "Confirmed": "#2ecc71",    # Green
        "Completed": "#27ae60",    # Dark Green
        "Cancelled": "#e74c3c",    # Red
    }
    return colors.get(status, "#7f8c8d")  # Default gray




def generate_document_expiry_template(document, message: str) -> str:
    """HTML template for document expiry notifications"""
    return f"""
    <html>
    <body style="font-family: Arial, sans-serif; line-height: 1.6;">
        <div style="max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd;">
            <h2 style="color: #2c3e50;">Gov-Portal Document Expiry Notice</h2>
            
            <div style="background-color: #fff8e1; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
                <p><strong>Document Type:</strong> {document.document_type}</p>
                <p><strong>Expiry Date:</strong> <span style="color: #d32f2f;">
                    {document.expiry_date.strftime('%Y-%m-%d')}
                </span></p>
                <p><strong>Days Remaining:</strong> {(document.expiry_date - datetime.now()).days}</p>
            </div>
            
            <p>{message}</p>
            
            <div style="margin-top: 20px;">
                <a href="{settings.FRONTEND_URL}/documents/renew/{document.document_id}"
                   style="background-color: #1976d2; color: white; padding: 10px 15px; 
                          text-decoration: none; border-radius: 4px;">
                    Renew Document
                </a>
            </div>
            
            <div style="margin-top: 30px; font-size: 0.9em; color: #7f8c8d;">
                <p>This is an automated notification. Please ignore if already renewed.</p>
            </div>
        </div>
    </body>
    </html>
    """