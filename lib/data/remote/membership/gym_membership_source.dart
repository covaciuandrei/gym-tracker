import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_tracker/data/mappers/gym_membership_mapper.dart';
import 'package:gym_tracker/data/remote/membership/gym_membership_dto.dart';
import 'package:gym_tracker/model/gym_membership.dart';
import 'package:injectable/injectable.dart';

@injectable
class GymMembershipSource {
  const GymMembershipSource(this._db, this._mapper);

  final FirebaseFirestore _db;
  final GymMembershipMapper _mapper;

  CollectionReference<GymMembershipDto> _membershipsRef(String userId) => _db
      .collection('users')
      .doc(userId)
      .collection('gymMemberships')
      .withConverter<GymMembershipDto>(
        fromFirestore: (snapshot, _) {
          final dto = GymMembershipDto.fromJson(snapshot.data() ?? const {});
          return GymMembershipDto(
            id: snapshot.id,
            gymName: dto.gymName,
            startDate: dto.startDate,
            durationMonths: dto.durationMonths,
            validUntil: dto.validUntil,
            priceMinor: dto.priceMinor,
            currency: dto.currency,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt,
          );
        },
        toFirestore: (dto, _) => dto.toJson(),
      );

  Future<List<GymMembership>> getAll({required String userId}) async {
    final snapshot = await _membershipsRef(userId).orderBy('start_date', descending: true).get();
    return snapshot.docs.map((document) => _mapper.mapDto(document.data())).toList(growable: false);
  }

  Future<GymMembership?> getById({required String userId, required String membershipId}) async {
    final snapshot = await _membershipsRef(userId).doc(membershipId).get();
    final dto = snapshot.data();
    return dto == null ? null : _mapper.mapDto(dto);
  }

  Future<String> create({required String userId, required GymMembership membership}) async {
    final dto = _mapper.mapModel(
      model: membership,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    );
    final document = await _membershipsRef(userId).add(dto);
    return document.id;
  }

  Future<void> update({required String userId, required GymMembership membership}) async {
    final dto = _mapper.mapModel(
      model: membership,
      createdAt: membership.createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(membership.createdAt!),
      updatedAt: FieldValue.serverTimestamp(),
    );
    await _membershipsRef(userId).doc(membership.id).set(dto);
  }

  Future<void> delete({required String userId, required String membershipId}) =>
      _membershipsRef(userId).doc(membershipId).delete();
}
