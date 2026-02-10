import 'mysql.dart';

class DbManager {
  final _connector = MySqlConnector();

  // query
  Future<List<Map<String, dynamic>>> query(String sql, [List<Object?>? params]) async {
    try {
      final conn = await _connector.connection;
      final results = await conn.query(sql, params);
      
      return results.map((row) => row.fields).toList();
    } catch (e) {
      print("Database Error: $e");
      rethrow; 
    }
  }

  // insert, update, delete
  Future<void> execute(String sql, [List<Object?>? params]) async {
    final conn = await _connector.connection;
    await conn.query(sql, params);
  }
}