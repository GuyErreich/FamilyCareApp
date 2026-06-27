import 'package:family_care_scheduler/features/auth/data/dto/app_user_dto.dart';
import 'package:family_care_scheduler/features/unavailability/domain/entities/unavailability.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'unavailability_dto.freezed.dart';
part 'unavailability_dto.g.dart';

@freezed
class UnavailabilityDto with _$UnavailabilityDto {
  const factory UnavailabilityDto({
    required String familyId,
    required String userId,
    @TimestampConverter() required DateTime date,
    required int startHour,
    required int startMinute,
    required int durationMinutes,
    @TimestampConverter() required DateTime endTime,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _UnavailabilityDto;

  factory UnavailabilityDto.fromJson(Map<String, dynamic> json) =>
      _$UnavailabilityDtoFromJson(json);
}

extension UnavailabilityDtoX on UnavailabilityDto {
  Unavailability toDomain(String id) => Unavailability(
        id: id,
        familyId: familyId,
        userId: userId,
        date: DateTime(date.year, date.month, date.day),
        startTime: TimeOfDay(hour: startHour, minute: startMinute),
        durationMinutes: durationMinutes,
        endTime: endTime,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static UnavailabilityDto fromDomain(Unavailability block) => UnavailabilityDto(
        familyId: block.familyId,
        userId: block.userId,
        date: DateTime(block.date.year, block.date.month, block.date.day),
        startHour: block.startTime.hour,
        startMinute: block.startTime.minute,
        durationMinutes: block.durationMinutes,
        endTime: block.endTime,
        createdAt: block.createdAt,
        updatedAt: block.updatedAt,
      );
}
