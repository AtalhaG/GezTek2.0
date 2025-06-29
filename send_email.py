import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import json
import sys

def send_email(recipient_name, user_type, user_email):
    # E-posta ayarları
    sender_email = "admngeztek@gmail.com"
    sender_password = "jyalcltdpassaxvx"
    receiver_email = "geztek2025@gmail.com"

    # E-posta içeriği
    message = MIMEMultipart()
    message["From"] = sender_email
    message["To"] = receiver_email
    message["Subject"] = "Yeni Kullanıcı Kaydı"

    html = f"""
    <h1>Yeni Kullanıcı Kaydı</h1>
    <p>Yeni bir {user_type} kaydı oluşturuldu.</p>
    <p><strong>Kullanıcı Bilgileri:</strong></p>
    <ul>
        <li>Ad Soyad: {recipient_name}</li>
        <li>E-posta: {user_email}</li>
        <li>Hesap Türü: {user_type}</li>
    </ul>
    <br>
    <p>Bu e-posta otomatik olarak gönderilmiştir.</p>
    """
    message.attach(MIMEText(html, "html"))

    try:
        server = smtplib.SMTP("smtp.gmail.com", 587)
        server.starttls()
        server.login(sender_email, sender_password)
        server.send_message(message)
        server.quit()
        return True
    except Exception as e:
        print(f"E-posta gönderme hatası: {str(e)}", file=sys.stderr)
        return False

if __name__ == "__main__":
    try:
        # Flutter'dan gelen JSON verisini al
        if len(sys.argv) > 1:
            raw_input = ' '.join(sys.argv[1:])
            
            # JSON'ı parse et
            data = json.loads(raw_input)
            
            # Gerekli alanları kontrol et
            required_fields = ['recipientName', 'userType', 'userEmail']
            if not all(field in data for field in required_fields):
                print("Hata: Eksik bilgi - recipientName, userType ve userEmail gereklidir", file=sys.stderr)
                sys.exit(1)
                
            # E-posta gönder
            if send_email(data['recipientName'], data['userType'], data['userEmail']):
                print("E-posta başarıyla gönderildi!")
                sys.exit(0)
            else:
                sys.exit(1)
        else:
            print("Kullanım: python send_email.py '{\"recipientName\":\"İsim\",\"userType\":\"Tip\",\"userEmail\":\"email@ornek.com\"}'", file=sys.stderr)
            sys.exit(1)
            
    except Exception as e:
        print(f"Kritik hata: {str(e)}", file=sys.stderr)
        sys.exit(1)