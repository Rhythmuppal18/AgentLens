/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class RoomException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  RoomException._({
    required this.message,
    required this.statusCode,
  });

  factory RoomException({
    required String message,
    required int statusCode,
  }) = _RoomExceptionImpl;

  factory RoomException.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoomException(
      message: jsonSerialization['message'] as String,
      statusCode: jsonSerialization['statusCode'] as int,
    );
  }

  String message;

  int statusCode;

  /// Returns a shallow copy of this [RoomException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RoomException copyWith({
    String? message,
    int? statusCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoomException',
      'message': message,
      'statusCode': statusCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RoomException',
      'message': message,
      'statusCode': statusCode,
    };
  }

  @override
  String toString() {
    return 'RoomException(message: $message, statusCode: $statusCode)';
  }
}

class _RoomExceptionImpl extends RoomException {
  _RoomExceptionImpl({
    required String message,
    required int statusCode,
  }) : super._(
         message: message,
         statusCode: statusCode,
       );

  /// Returns a shallow copy of this [RoomException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RoomException copyWith({
    String? message,
    int? statusCode,
  }) {
    return RoomException(
      message: message ?? this.message,
      statusCode: statusCode ?? this.statusCode,
    );
  }
}
