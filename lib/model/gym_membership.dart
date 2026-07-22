import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:gym_tracker/core/constants/currencies.dart';

const Set<String> supportedMembershipCurrencies = supportedCurrencyCodes;

enum MembershipDuration {
  oneMonth(months: 1),
  threeMonths(months: 3),
  sixMonths(months: 6),
  twelveMonths(months: 12);

  const MembershipDuration({required this.months});

  final int months;

  DateTime validUntilFrom(DateTime startDate) {
    final normalizedStart = _dateOnly(startDate);
    if (this == MembershipDuration.oneMonth) {
      return DateTime(normalizedStart.year, normalizedStart.month, normalizedStart.day + 30);
    }

    final zeroBasedTargetMonth = normalizedStart.month - 1 + months;
    final targetYear = normalizedStart.year + zeroBasedTargetMonth ~/ 12;
    final targetMonth = zeroBasedTargetMonth % 12 + 1;
    final lastDayOfTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    final targetDay = normalizedStart.day > lastDayOfTargetMonth ? lastDayOfTargetMonth : normalizedStart.day;
    return DateTime(targetYear, targetMonth, targetDay);
  }

  static MembershipDuration fromMonths(int months) => switch (months) {
    3 => MembershipDuration.threeMonths,
    6 => MembershipDuration.sixMonths,
    12 => MembershipDuration.twelveMonths,
    _ => MembershipDuration.oneMonth,
  };
}

@immutable
class GymMembershipDraft extends Equatable {
  const GymMembershipDraft({
    required this.gymName,
    required this.startDate,
    required this.duration,
    required this.priceMinor,
    required this.currency,
  });

  factory GymMembershipDraft.fromMembership(GymMembership membership, {DateTime? startDate}) {
    return GymMembershipDraft(
      gymName: membership.gymName,
      startDate: startDate ?? membership.startDate,
      duration: membership.duration,
      priceMinor: membership.priceMinor,
      currency: membership.currency,
    );
  }

  final String gymName;
  final DateTime startDate;
  final MembershipDuration duration;
  final int priceMinor;
  final String currency;

  DateTime get validUntil => duration.validUntilFrom(startDate);

  @override
  List<Object?> get props => [gymName, startDate, duration, priceMinor, currency];
}

@immutable
class GymMembership extends Equatable {
  const GymMembership({
    required this.id,
    required this.gymName,
    required this.startDate,
    required this.durationMonths,
    required this.validUntil,
    required this.priceMinor,
    required this.currency,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String gymName;
  final DateTime startDate;
  final int durationMonths;
  final DateTime validUntil;
  final int priceMinor;
  final String currency;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MembershipDuration get duration => MembershipDuration.fromMonths(durationMonths);

  bool isUpcomingAt(DateTime date) => _dateOnly(date).isBefore(_dateOnly(startDate));

  bool isExpiredAt(DateTime date) => _dateOnly(date).isAfter(_dateOnly(validUntil));

  bool isActiveAt(DateTime date) => !isUpcomingAt(date) && !isExpiredAt(date);

  int daysRemainingAt(DateTime date) {
    if (isExpiredAt(date)) return 0;
    return _dateOnly(validUntil).difference(_dateOnly(date)).inDays;
  }

  @override
  List<Object?> get props => [
    id,
    gymName,
    startDate,
    durationMonths,
    validUntil,
    priceMinor,
    currency,
    createdAt,
    updatedAt,
  ];
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
