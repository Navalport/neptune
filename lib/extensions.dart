extension MapOmit<K, V> on Map<K, V> {
  Map<K, V> omit(List<String> keys) {
    removeWhere((key, _) => keys.contains(key));
    return this;
  }
}
