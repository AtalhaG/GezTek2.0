const {onCall} = require("firebase-functions/v2/https");
const {setGlobalOptions} = require("firebase-functions/v2");
const nodemailer = require("nodemailer");
const admin = require("firebase-admin");

// Global ayarlar
setGlobalOptions({
  region: "europe-west1",
  memory: "512MiB",
});

// Firebase Admin başlatma
if (admin.apps.length === 0) {
  admin.initializeApp();
}

// Nodemailer konfigürasyonu
const transporter = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 465,
  secure: true,
  auth: {
    user: "admngeztek@gmail.com",
    pass: "wqep zkan xcyp sytf",
  },
});

// Admin bildirim e-postası gönderen fonksiyon
exports.sendAdminNotification = onCall(async (request) => {
  const data = request.data;

  // Veri validasyonu
  if (!data || typeof data !== "object") {
    throw new onCall.HttpsError(
      "invalid-argument",
      "recipientName, userType ve userEmail içeren bir obje gönderilmelidir",
    );
  }

  const {recipientName, userType, userEmail, tcKimlikNo, ruhsatNo} = data;

  if (!recipientName || !userType || !userEmail) {
    throw new onCall.HttpsError(
      "invalid-argument",
      "Zorunlu alanlar eksik: recipientName, userType veya userEmail",
    );
  }

  // E-posta format kontrolü
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(userEmail)) {
    throw new onCall.HttpsError("invalid-argument", "Geçersiz e-posta formatı");
  }

  // Admin e-posta şablonu
  const adminMailOptions = {
    from: "GezTek <admngeztek@gmail.com>",
    to: "geztek2025@gmail.com",
    subject: `Yeni ${userType === "rehber" ? "Rehber" : "Turist"} Kaydı`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; 
        padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px; 
        background-color: #ffffff;">
        
        <div style="background-color: #4CAF50; padding: 15px; border-radius: 8px; 
          margin-bottom: 20px;">
          <h2 style="color: white; margin: 0; text-align: center;">
            Yeni Kullanıcı Kaydı
          </h2>
        </div>

        <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; 
          margin-bottom: 20px;">
          <div style="margin-bottom: 15px;">
            <span style="font-weight: bold; color: #4CAF50;">Kullanıcı Tipi:</span>
            <span style="margin-left: 10px; color: #2c3e50;">
              ${userType === "rehber" ? "Rehber" : "Turist"}
            </span>
          </div>
          
          <div style="margin-bottom: 15px;">
            <span style="font-weight: bold; color: #4CAF50;">İsim:</span>
            <span style="margin-left: 10px; color: #2c3e50;">${recipientName}</span>
          </div>
          
          <div style="margin-bottom: 15px;">
            <span style="font-weight: bold; color: #4CAF50;">E-posta:</span>
            <span style="margin-left: 10px; color: #2c3e50;">${userEmail}</span>
          </div>
          
          <div style="margin-bottom: 15px;">
            <span style="font-weight: bold; color: #4CAF50;">Tarih:</span>
            <span style="margin-left: 10px; color: #2c3e50;">
              ${new Date().toLocaleString("tr-TR")}
            </span>
          </div>
          
          ${userType === "rehber" ? `
            <div style="margin-bottom: 15px;">
              <span style="font-weight: bold; color: #4CAF50;">TC Kimlik No:</span>
              <span style="margin-left: 10px; color: #2c3e50;">
                ${tcKimlikNo ? tcKimlikNo : "Belirtilmemiş"}
              </span>
            </div>
            <div style="margin-bottom: 15px;">
              <span style="font-weight: bold; color: #4CAF50;">Ruhsat No:</span>
              <span style="margin-left: 10px; color: #2c3e50;">
                ${ruhsatNo ? ruhsatNo : "Belirtilmemiş"}
              </span>
            </div>
          ` : ""}
        </div>

        <div style="text-align: center; color: #666; font-size: 12px; margin-top: 20px;">
          <p>Bu e-posta GezTek sisteminden otomatik olarak gönderilmiştir.</p>
          <p>© ${new Date().getFullYear()} GezTek. Tüm hakları saklıdır.</p>
        </div>
      </div>
    `,
  };

  try {
    await transporter.verify();
    const result = await transporter.sendMail(adminMailOptions);
    console.log("Admin e-postası gönderildi:", result.messageId);
    return {
      success: true,
      message: "Admin bildirimi başarıyla gönderildi",
      emailId: result.messageId,
    };
  } catch (error) {
    console.error("Admin e-postası gönderme hatası:", error);
    throw new onCall.HttpsError(
      "internal",
      "Admin bildirimi gönderilirken bir hata oluştu",
      {
        technicalDetails: error.message,
      },
    );
  }
});

exports.sendUserWelcomeEmail = onCall(async (request) => {
  const data = request.data;

  // Veri validasyonu
  if (!data || typeof data !== "object") {
    throw new onCall.HttpsError(
      "invalid-argument",
      "recipientName, userType, userEmail ve verificationCode içeren bir obje gönderilmelidir",
    );
  }

  const {recipientName, userType, userEmail, verificationCode} = data;

  if (!recipientName || !userType || !userEmail || !verificationCode) {
    throw new onCall.HttpsError(
      "invalid-argument",
      "Zorunlu alanlar eksik: recipientName, userType, userEmail veya verificationCode",
    );
  }

  // E-posta format kontrolü
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(userEmail)) {
    throw new onCall.HttpsError("invalid-argument", "Geçersiz e-posta formatı");
  }

  // Kullanıcı e-posta şablonu (doğrulama kodu ile)
  const userMailOptions = {
    from: "GezTek <admngeztek@gmail.com>",
    to: userEmail,
    subject: "GezTek'e Hoş Geldiniz! - Hesap Doğrulama",
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; 
        padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;">

        <h2 style="color: #2c3e50;">Merhaba ${recipientName},</h2>
        <p>GezTek'e hoş geldiniz! Kaydınız başarıyla oluşturuldu.</p>
        <p>Artık ${userType === "rehber" ? "rehber" : "turist"} olarak 
          platformumuzu kullanmaya başlayabilirsiniz.</p>
        
        <div style="background-color: #f5f5f5; padding: 15px; border-radius: 5px; 
          margin: 20px 0; text-align: center;">
          <h3 style="margin-top: 0;">Hesap Doğrulama Kodunuz:</h3>
          <div style="font-size: 24px; font-weight: bold; letter-spacing: 2px; 
            color: #4285f4; margin: 10px 0;">
            ${verificationCode}
          </div>
          <p style="font-size: 12px; color: #666;">
            Bu kodu uygulamada ilgili alana girerek hesabınızı doğrulayabilirsiniz.
          </p>
        </div>

        <p>Veya aşağıdaki butona tıklayarak doğrulama sayfasına gidebilirsiniz:</p>
        <a href="https://geztekapp.com/dogrulama?code=${verificationCode}&email=${
  encodeURIComponent(userEmail)
}" 
          style="display: inline-block; padding: 10px 20px; background-color: #4285f4; 
          color: white; text-decoration: none; border-radius: 4px; margin: 15px 0;">
          Hesabımı Doğrula
        </a>
        
        <p>Herhangi bir sorunuz olursa 
          <a href="mailto:destek@geztek.com">destek@geztek.com</a> 
          adresine yazabilirsiniz.</p>
        <br>
        <p>Saygılarımızla,</p>
        <p><strong>GezTek Ekibi</strong></p>
      </div>
    `,
  };

  try {
    await transporter.verify();
    const result = await transporter.sendMail(userMailOptions);
    console.log("Doğrulama kodu ile kullanıcı e-postası gönderildi:", {
      email: userEmail,
      messageId: result.messageId,
    });
    return {
      success: true,
      message: "Doğrulama kodu içeren hoş geldin e-postası başarıyla gönderildi",
      emailId: result.messageId,
    };
  } catch (error) {
    console.error("Doğrulama e-postası gönderme hatası:", {
      email: userEmail,
      error: error.message,
    });
    throw new onCall.HttpsError(
      "internal",
      "Doğrulama e-postası gönderilirken bir hata oluştu",
      {
        technicalDetails: error.message,
      },
    );
  }
});
