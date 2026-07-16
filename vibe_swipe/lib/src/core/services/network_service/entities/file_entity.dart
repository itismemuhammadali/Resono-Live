class FileEntity {
  final String name;
  final String path;

  FileEntity({required this.name, required this.path});

  @override
  String toString() {
    return 'FileEntity(name: $name, path: $path)';
  }
}
