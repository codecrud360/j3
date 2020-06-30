import 'package:j3enterprise/src/database/moor_database.dart';
import 'package:j3enterprise/src/models/application_logger_model.dart';
import 'package:moor/moor.dart';

part 'app_logger_crud.g.dart';

@UseDao(
  tables: [ApplicationLogger],
  // queries: {
  //   'deleteFromTop1000Row':
  //       'DELETE FROM application_logger WHERE id in (SELECT id FROM application_logger ORDER BY log_date_time LIMIT 100);'
  // },
)
class ApplicationLoggerDao extends DatabaseAccessor<AppDatabase>
    with _$ApplicationLoggerDaoMixin {
  final AppDatabase db;
  ApplicationLoggerDao(this.db) : super(db);

  Future<List<ApplicationLoggerData>> getAllAppLog() {
    return (select(db.applicationLogger).get());
  }

  Future<List<ApplicationLoggerData>> getAppLog(String exportStatus) {
    return (select(db.applicationLogger)
          ..where((t) => t.exportStatus.equals(exportStatus)))
        .get();
  }

  Stream<List<ApplicationLoggerData>> watchAllAppLog() {
    return (select(db.applicationLogger).watch());
  }

  Future updateAppLogger(
      ApplicationLoggerCompanion applicationLoggerCompanion, int id) {
    return (update(db.applicationLogger)..where((t) => t.id.equals(id))).write(
        ApplicationLoggerCompanion(
            exportStatus: applicationLoggerCompanion.exportStatus,
            exportDateTime: applicationLoggerCompanion.exportDateTime));
  }

  Future updateAppLoggerReplace(ApplicationLoggerData data) {
    return update(db.applicationLogger).replace(data);
  }

  Future insertAppLog(ApplicationLoggerCompanion applicationLoggerData) =>
      into(db.applicationLogger).insert(applicationLoggerData);

  Future deleteAllAppLog() => delete(db.applicationLogger).go();

  Future deleteById(int id) {
    return (delete(db.applicationLogger)..where((t) => t.id.equals(id))).go();
  }

//  Stream<List<ApplicationLoggerData>> purgeData(int limit) {
//    return customSelectStream(
//      'DELETE FROM application_logger WHERE id in (SELECT id FROM application_logger ORDER BY log_date_time LIMIT $limit);',
//      readsFrom: {applicationLogger},
//    ).map((rows) {
//      return rows
//          .map((row) => ApplicationLoggerData.fromData(row.data, db))
//          .toList();
//    });
//  }
//
//  Stream<List<ApplicationLoggerData>> purgeDatabyExportStatus(
//      String exportStatus) {
//    return customSelectStream(
//      'DELETE FROM application_logger WHERE export_status = $exportStatus);',
//      readsFrom: {applicationLogger},
//    ).map((rows) {
//      return rows
//          .map((row) => ApplicationLoggerData.fromData(row.data, db))
//          .toList();
//    });
//  }

  Future deleteAppLog(ApplicationLoggerCompanion applicationLoggerCompanion) =>
      delete(applicationLogger).delete(applicationLoggerCompanion);
}
