const functions = require("firebase-functions");
const nodemailer = require("nodemailer");
const admin = require("firebase-admin");

// Initialize Firebase Admin if not already done
if (admin.apps.length === 0) {
  admin.initializeApp();
}

// Configure Nodemailer transporter
const transporter = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 465,
  secure: true,
  auth: {
    user: "admngeztek@gmail.com",
    pass: "wqep zkan xcyp sytf",
  },
});

exports.sendAdminNotification = functions.https.onCall(async (data, context) => {
  // Validate authentication if needed
  // if (!context.auth) {
  //   throw new functions.https.HttpsError(
  //     'unauthenticated',
  //     'Only authenticated users can send emails'
  //   );
  // }

  // Validate input data
  if (!data || typeof data !== "object") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Function must be called with an object containing recipientName, userType, and userEmail",
    );
  }

  const {recipientName, userType, userEmail} = data;

  if (!recipientName || !userType || !userEmail) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing required fields: recipientName, userType, or userEmail",
    );
  }

  // Verify email format
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(userEmail)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Invalid email format",
    );
  }

  // Prepare email options
  const adminMailOptions = {
    from: "GezTek <admngeztek@gmail.com>",
    to: "geztek2025@gmail.com",
    subject: `Yeni ${userType === "rehber" ? "Rehber" : "Turist"} Kaydı`,
    html: `
      <h2>Yeni Kullanıcı Kaydı</h2>
      <p><strong>Kullanıcı Tipi:</strong> ${userType}</p>
      <p><strong>İsim:</strong> ${recipientName}</p>
      <p><strong>E-posta:</strong> ${userEmail}</p>
      <p><strong>Tarih:</strong> ${new Date().toLocaleString("tr-TR")}</p>
    `,
  };

  const userMailOptions = {
    from: "GezTek <admngeztek@gmail.com>",
    to: userEmail,
    subject: "GezTek'e Hoş Geldiniz!",
    html: `
      <h2>Merhaba ${recipientName},</h2>
      <p>GezTek'e hoş geldiniz! Kaydınız başarıyla oluşturuldu.</p>
      <p>Artık ${
  userType === "rehber" ? "rehber" : "turist"
} olarak platformumuzu kullanmaya başlayabilirsiniz.</p>
      <p>Herhangi bir sorunuz olursa bizimle iletişime geçmekten çekinmeyin.</p>
      <br>
      <p>Saygılarımızla,</p>
      <p>GezTek Ekibi</p>
    `,
  };

  try {
    // Verify connection configuration
    await transporter.verify();

    // Send emails
    const adminResult = await transporter.sendMail(adminMailOptions);
    console.log("Admin email sent:", adminResult.messageId);

    const userResult = await transporter.sendMail(userMailOptions);
    console.log("User email sent:", userResult.messageId);

    return {
      success: true,
      message: "E-postalar başarıyla gönderildi",
      adminMessageId: adminResult.messageId,
      userMessageId: userResult.messageId,
    };
  } catch (error) {
    console.error("Email sending error:", error);
    throw new functions.https.HttpsError(
      "internal",
      "E-posta gönderilirken bir hata oluştu",
      {
        errorDetails: error.message,
        stack: error.stack,
      },
    );
  }
});
