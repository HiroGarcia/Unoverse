import 'package:firebase_auth/firebase_auth.dart';
import 'package:unoverse/data/services/matche_service.dart';
import 'package:unoverse/domain/entity/matche_entity.dart';
import 'package:uuid/uuid.dart';

class MatcheController {
  MatcheService matcheService = MatcheService();
  FirebaseAuth auth = FirebaseAuth.instance;

  void addMatche({required String groupId, required Map<String, int> config}) {
    MatcheEntity matche = MatcheEntity(
      id: Uuid().v4(),
      dateTime: DateTime.now(),
      registerByUid: auth.currentUser!.uid,
      poitns: config,
    );

    try {
      matcheService.addMatche(matche: matche, groupId: groupId);
    } on FirebaseException catch (e) {
      print(e.code);
    } catch (e) {
      print(e);
    }
  }
}
