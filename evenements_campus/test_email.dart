import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

void main() async {
  const smtpUser = 'rafanomezantsoaherindrainyelie@gmail.com';
  const smtpPassword = 'atwqvdtrdmifzqks';
  const toEmail = 'rafanomezantsoaherindrainyelie@gmail.com'; // REMPLACEZ PAR VOTRE EMAIL
  
  print('Test d\'envoi d\'email...');
  print('De: $smtpUser');
  print('À: $toEmail');
  print('═══════════════════════════════════════════');
  
  // Configuration SMTP Gmail (méthode simplifiée)
  final smtpServer = gmail(smtpUser, smtpPassword);
  
  final message = Message()
    ..from = Address(smtpUser, 'CampusEvent Test')
    ..recipients.add(toEmail)
    ..subject = 'Test d\'envoi d\'email - CampusEvent'
    ..html = '''
      <h1>Test CampusEvent</h1>
      <p>Ceci est un test de configuration SMTP.</p>
      <p><strong>Code de test: 123456</strong></p>
      <p>Si vous recevez cet email, la configuration est correcte!</p>
    ''';
  
  try {
    await send(message, smtpServer);
    print('✅ Email envoyé avec succès!');
    print('Vérifiez votre boîte de réception: $toEmail');
  } on MailerException catch (e) {
    print('❌ Erreur Mailer: $e');
    for (var p in e.problems) {
      print('Problème: $p');
    }
  } catch (e) {
    print('Erreur: $e');
    print('Détails: ${e.toString()}');
  }
}