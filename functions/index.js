const {onCall} = require("firebase-functions/v2/https");
const {setGlobalOptions} = require("firebase-functions/v2");
const nodemailer = require("nodemailer");
const admin = require("firebase-admin");

// Global ayarlar (bölge ve diğer konfigürasyonlar)
setGlobalOptions({
  region: "europe-west1",
  memory: "512MiB", // İsteğe bağlı bellek ayarı
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

exports.sendAdminNotification = onCall(async (request) => {
  // Gelen verileri ayıkla
  const data = request.data;
  const context = request.auth;

  // Giriş doğrulama (isteğe bağlı)
  // if (!context) {
  //   throw new onCall.HttpsError(
  //     "unauthenticated",
  //     "Sadece yetkili kullanıcılar e-posta gönderebilir"
  //   );
  // }

  // Veri validasyonu
  if (!data || typeof data !== "object") {
    throw new onCall.HttpsError(
      "invalid-argument",
      "recipientName, userType ve userEmail içeren bir obje gönderilmelidir",
    );
  }

  const {recipientName, userType, userEmail} = data;

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

  // E-posta şablonları
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
      ${userType === "rehber" ? `
        <p><strong>TC Kimlik No:</strong> ${data.tcKimlikNo || "Belirtilmemiş"}</p>
        <p><strong>Ruhsat No:</strong> ${data.ruhsatNo || "Belirtilmemiş"}</p>
      ` : ""}
      ${context ? `<p><strong>Kullanıcı ID:</strong> ${context.uid}</p>` : ""}
    `,
  };

  const userMailOptions = {
    from: "GezTek <admngeztek@gmail.com>",
    to: userEmail,
    subject: "GezTek'e Hoş Geldiniz!",
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; 
        padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;">
        <img src="https://example.com/geztek-logo.png" alt="GezTek Logo" 
          style="max-width: 200px; display: block; margin: 0 auto 20px;">
        <h2 style="color: #2c3e50;">Merhaba ${recipientName},</h2>
        <p>GezTek'e hoş geldiniz! Kaydınız başarıyla oluşturuldu.</p>
        <p>Artık ${userType === "rehber" ? "rehber" : "turist"} olarak 
          platformumuzu kullanmaya başlayabilirsiniz.</p>
        <a href="https://geztekapp.com/giris" 
          style="display: inline-block; padding: 10px 20px; background-color: #4285f4; 
          color: white; text-decoration: none; border-radius: 4px; margin: 15px 0;">
          Giriş Yap
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
    // SMTP bağlantısını test et
    await transporter.verify();
    console.log("SMTP bağlantısı başarılı");

    // E-postaları paralel gönder
    const [adminResult, userResult] = await Promise.all([
      transporter.sendMail(adminMailOptions),
      transporter.sendMail(userMailOptions),
    ]);

    console.log("E-postalar gönderildi:", {
      admin: adminResult.messageId,
      user: userResult.messageId,
    });

    return {
      success: true,
      message: "E-postalar başarıyla gönderildi",
      details: {
        adminEmailId: adminResult.messageId,
        userEmailId: userResult.messageId,
      },
    };
  } catch (error) {
    console.error("E-posta gönderme hatası:", {
      message: error.message,
      stack: error.stack,
    });

    throw new onCall.HttpsError(
      "internal",
      "E-posta gönderilirken bir hata oluştu",
      {
        technicalDetails: error.message,
      },
    );
  }
});
