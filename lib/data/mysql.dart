import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mysql1/mysql1.dart';

class MySqlConnector {
  static final MySqlConnector _instance = MySqlConnector._internal();
  factory MySqlConnector() => _instance;
  MySqlConnector._internal();

  MySqlConnection? _connect;

  Future<MySqlConnection> get connection async {
    if (_connect !=  null) return _connect!;

    final settings = ConnectionSettings(
      host: dotenv.env['DB_HOST'] ?? "localhost",
      port: int.parse(dotenv.env['DB_PORT'] ?? "3306"),
      db: dotenv.env['DB_NAME'],
      user: dotenv.env['DB_USER'],
      password: dotenv.env['DB_PASS'],
    );

    print("Connecting to: ${dotenv.env['DB_HOST']}");

    _connect = await MySqlConnection.connect(settings);
    return _connect!;    
  }
}
