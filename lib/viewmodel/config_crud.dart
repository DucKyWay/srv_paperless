abstract class ConfigCrud {
  Future<void> createItem(String key, String label);
  Future<void> updateItem(String id, String key, String label);
  Future<void> deleteItem(String id);
}
