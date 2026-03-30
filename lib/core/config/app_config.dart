class AppConfig {
  // For local development with PHYSICAL DEVICE:
  // Using your computer's IP address: 192.168.1.7
  // Make sure both phone and computer are on the SAME WiFi network!
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.7:8000',  // Physical Device - YOUR COMPUTER'S IP
  );
  
  // Alternative configurations:
  // defaultValue: 'http://10.0.2.2:8000',  // For Android Emulator
  // defaultValue: 'http://localhost:8000',  // For iOS Simulator or Web
  // defaultValue: 'https://yamenmod912.pythonanywhere.com',  // Production server
}

