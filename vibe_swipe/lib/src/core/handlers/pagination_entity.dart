class PaginationEntity {
  int page;
  int limit;

  PaginationEntity({this.page = 1, this.limit = 10});

  Map<String, dynamic> toJson() {
    return {'page': page, 'limit': limit};
  }
}
