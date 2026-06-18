import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:http/http.dart' as http;

class EmailService {
  static const String smtpUser = 'rafanomezantsoaherindrainyelie@gmail.com';
  static const String smtpPassword = 'atwqvdtrdmifzqks';

  static Future<Map<String, dynamic>> sendResetCodeEmail(String toEmail, String code, String name, String role) async {
    try {
      print('[EMAIL] Début envoi vers $toEmail pour rôle: $role');
      
      final hasConnection = await _checkInternetConnection();
      if (!hasConnection) {
        print('[EMAIL] Pas de connexion Internet');
        return {
          'success': false,
          'message': 'Pas de connexion Internet. Vérifiez votre connexion.',
          'code': '',
        };
      }
      
      final smtpServer = gmail(smtpUser, smtpPassword);
      final currentYear = DateTime.now().year;
      final formattedCode = code.trim().replaceAll(' ', '');
      
      final message = Message()
        ..from = Address(smtpUser, 'CampusEvent')
        ..recipients.add(toEmail)
        ..subject = 'Code de réinitialisation - CampusEvent'
        ..html = _buildEmailHtml(name, formattedCode, currentYear, role);
      
      print('[EMAIL] Envoi du message...');
      await send(message, smtpServer).timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw Exception('Timeout - Le serveur met trop de temps à répondre'),
      );
      
      print('[EMAIL] Code envoyé avec succès à $toEmail');
      return {
        'success': true,
        'message': 'Email envoyé avec succès',
        'code': formattedCode,
      };
      
    } on MailerException catch (e) {
      print('[EMAIL] Erreur Mailer: $e');
      return {
        'success': false,
        'message': 'Erreur d\'envoi: ${e.toString()}',
        'code': '',
      };
    } catch (e) {
      print('[EMAIL] Erreur générale: $e');
      return {
        'success': false,
        'message': 'Erreur: ${e.toString()}',
        'code': '',
      };
    }
  }
  
  static Future<bool> _checkInternetConnection() async {
    try {
      final result = await http.get(Uri.parse('https://www.google.com')).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Timeout'),
      );
      return result.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  static String _getRoleLabel(String role) {
    switch (role) {
      case 'admin': return 'Administrateur';
      case 'organizer': return 'Organisateur';
      case 'club_president': return 'Chef de club';
      default: return 'Étudiant';
    }
  }
  
  static String _getRoleColor(String role) {
    switch (role) {
      case 'admin': return '#9C27B0';
      case 'organizer': return '#2196F3';
      case 'club_president': return '#4CAF50';
      default: return '#FF9800';
    }
  }
  
  static String _buildEmailHtml(String name, String code, int year, String role) {
    final roleLabel = _getRoleLabel(role);
    final roleColor = _getRoleColor(role);
    
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Réinitialisation mot de passe - CampusEvent</title>
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background-color: #f0f0f0; padding: 20px; line-height: 1.6; }
          .container { max-width: 550px; margin: 0 auto; background: #FFFFFF; border-radius: 24px; overflow: hidden; box-shadow: 0 15px 35px rgba(0,0,0,0.1); }
          .header { background: linear-gradient(135deg, #FF6D00, #FF8F3C); padding: 35px 25px; text-align: center; }
          .header h1 { color: #FFFFFF; font-size: 28px; margin: 0; font-weight: bold; }
          .role-badge { display: inline-block; margin-top: 12px; padding: 6px 16px; background: $roleColor; border-radius: 30px; color: white; font-size: 12px; font-weight: bold; }
          .content { padding: 35px 25px; background: #FFFFFF; text-align: center; }
          .greeting { font-size: 22px; font-weight: bold; color: #1A237E; margin-bottom: 15px; }
          .message { color: #444444; font-size: 15px; margin-bottom: 30px; }
          .code-container { margin: 25px 0 30px; }
          .code-card { background: linear-gradient(135deg, #FFF8E1, #FFE0B2); border-radius: 20px; padding: 20px 25px; border: 2px solid #FF6D00; display: inline-block; }
          .code-number { font-size: 48px; font-weight: 800; letter-spacing: 15px; color: #FF6D00; font-family: monospace; background: #FFFFFF; padding: 15px 20px; border-radius: 15px; }
          .expiry { color: #FF6D00; font-weight: bold; font-size: 14px; margin: 10px 0; }
          .warning-box { background: #1A237E; border-radius: 16px; padding: 20px; margin: 20px 0; }
          .warning-title { color: #FF6D00; font-weight: bold; font-size: 14px; margin-bottom: 12px; }
          .warning-text { color: #FFFFFF; font-size: 12px; margin: 6px 0; }
          .footer { background: #F8F9FA; padding: 20px; text-align: center; border-top: 1px solid #EEEEEE; }
          .footer p { margin: 5px 0; font-size: 11px; color: #999999; }
          @media (max-width: 500px) { .code-number { font-size: 28px; letter-spacing: 8px; padding: 12px; } }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>CampusEvent</h1>
            <div class="role-badge">$roleLabel</div>
          </div>
          <div class="content">
            <div class="greeting">Bonjour $name</div>
            <div class="message">Vous avez demandé la réinitialisation de votre mot de passe pour votre compte <strong>$roleLabel</strong>.</div>
            <div class="code-container">
              <div class="code-card">
                <div class="code-number">$code</div>
              </div>
            </div>
            <div class="expiry">Ce code est valable <strong>15 minutes</strong></div>
            <div class="warning-box">
              <div class="warning-title">⚠️ IMPORTANT</div>
              <div class="warning-text">• Ne partagez jamais ce code avec personne</div>
              <div class="warning-text">• Si vous n'êtes pas à l'origine, ignorez cet email</div>
              <div class="warning-text">• Ce code ne peut être utilisé qu'une seule fois</div>
            </div>
          </div>
          <div class="footer">
            <p>© $year CampusEvent - Tous droits réservés</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }
}