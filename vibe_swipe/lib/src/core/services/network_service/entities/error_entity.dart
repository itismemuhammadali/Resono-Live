import 'dart:convert';

ErrorModel errorModelFromJson(String str) => ErrorModel.fromJson(json.decode(str));

String errorModelToJson(ErrorModel data) => json.encode(data.toJson());

class ErrorModel {
  ErrorModel({
    this.message,
    this.status,
  });

  String? message;
  bool? status;

  factory ErrorModel.fromJson(Map<String, dynamic> json) => ErrorModel(
    message: json["message"] ?? "Something went wrong",
    status: json["status"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
  };
}
