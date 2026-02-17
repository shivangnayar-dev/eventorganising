import nodemailer from 'nodemailer';
import { env } from '../config/env.js';
import { logger } from '../config/logger.js';

// Create reusable transporter
const createTransporter = () => {
  // For development, use Gmail or a test account
  // For production, configure with your SMTP server
  if (env.environment === 'development') {
    // Use Gmail or other SMTP service
    // You can also use Ethereal Email for testing: https://ethereal.email
    return nodemailer.createTransport({
      host: process.env.SMTP_HOST || 'smtp.gmail.com',
      port: Number(process.env.SMTP_PORT || 587),
      secure: false, // true for 465, false for other ports
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS, // App password for Gmail
      },
    });
  }

  // Production SMTP configuration
  return nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: Number(process.env.SMTP_PORT || 587),
    secure: false,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });
};

export async function sendNodalOfficerAssignmentEmail(
  to: string,
  officerName: string,
  serviceTitle: string,
  serviceLocation: string,
  activationLink: string,
) {
  try {
    // If SMTP is not configured, just log the email
    if (!process.env.SMTP_USER || !process.env.SMTP_PASS) {
      logger.info('Email not sent - SMTP not configured. Email details:', {
        to,
        subject: 'Nodal Officer Assignment - Setup Your Account',
        activationLink,
      });
      logger.warn('To enable email sending, configure SMTP_USER and SMTP_PASS in .env file');
      return;
    }

    const transporter = createTransporter();

    const mailOptions = {
      from: `"Event Organising" <${process.env.SMTP_USER}>`,
      to,
      subject: 'Nodal Officer Assignment - Setup Your Account',
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #2196F3; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0; }
            .content { background-color: #f9f9f9; padding: 30px; border-radius: 0 0 5px 5px; }
            .button { display: inline-block; padding: 12px 30px; background-color: #2196F3; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
            .info-box { background-color: #e3f2fd; padding: 15px; border-radius: 5px; margin: 20px 0; }
            .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Welcome to Event Organising Platform</h1>
            </div>
            <div class="content">
              <h2>Hello ${officerName},</h2>
              <p>You have been assigned as a Nodal Officer for the following property:</p>
              
              <div class="info-box">
                <strong>Property:</strong> ${serviceTitle}<br>
                <strong>Location:</strong> ${serviceLocation}
              </div>

              <p>To access your dashboard and view assigned properties, please set up your account password by clicking the button below:</p>
              
              <div style="text-align: center;">
                <a href="${activationLink}" class="button">Setup Password & Access Dashboard</a>
              </div>

              <p style="margin-top: 30px;">Or copy and paste this link into your browser:</p>
              <p style="word-break: break-all; color: #2196F3;">${activationLink}</p>

              <p><strong>Note:</strong> This link will expire in 7 days. If you have any questions, please contact your manager.</p>
            </div>
            <div class="footer">
              <p>This is an automated message. Please do not reply to this email.</p>
            </div>
          </div>
        </body>
        </html>
      `,
      text: `
Hello ${officerName},

You have been assigned as a Nodal Officer for the following property:
- Property: ${serviceTitle}
- Location: ${serviceLocation}

To access your dashboard and view assigned properties, please set up your account password by visiting:

${activationLink}

This link will expire in 7 days.

If you have any questions, please contact your manager.

Best regards,
Event Organising Platform
      `,
    };

    const info = await transporter.sendMail(mailOptions);
    logger.info('Email sent successfully', {
      to,
      messageId: info.messageId,
    });
  } catch (error) {
    logger.error('Failed to send email', error);
    // Don't throw - log the error but don't fail the assignment
  }
}

