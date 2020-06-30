import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:j3enterprise/src/database/crud/backgroundjob/backgroundjob_schedule_crud.dart';
import 'package:j3enterprise/src/database/crud/prefrence/non_preference_crud.dart';
import 'package:j3enterprise/src/database/crud/prefrence/preference_crud.dart';
import 'package:j3enterprise/src/database/moor_database.dart';
import 'package:j3enterprise/src/resources/api_clients/api_client.dart';
import 'package:j3enterprise/src/resources/services/rest_api_service.dart';
import 'package:j3enterprise/src/resources/shared/function/update_backgroung_job_schedule_status.dart';
import 'package:j3enterprise/src/resources/shared/preferences/user_share_data.dart';
import 'package:j3enterprise/src/resources/shared/utils/custom_date_json_serializer.dart';
import 'package:logging/logging.dart';

class PreferenceRepository {
  var api = ApiClient.chopper.getService<RestApiService>();
  var db;

  static final _log = Logger('PreferenceRepository');
  UpdateBackgroundJobStatus updateBackgroundJobStatus;
  BackgroundJobScheduleDao backgroundJobScheduleDao;
  PreferenceDao preferenceDao;
  NonGlobalPreferenceDao nonGlobalPreferenceDao;

  UserSharedData userSharedData;

  PreferenceRepository() {
    db = AppDatabase();
    updateBackgroundJobStatus = new UpdateBackgroundJobStatus();
    backgroundJobScheduleDao = new BackgroundJobScheduleDao(db);
    preferenceDao = PreferenceDao(db);
    nonGlobalPreferenceDao = NonGlobalPreferenceDao(db);
    userSharedData = new UserSharedData();
  }

  Future<void> getPreferenceFromServer(String jobName) async {
    try {
      var isSchedulerEnable = await backgroundJobScheduleDao.getJob(jobName);
      if (isSchedulerEnable != null) {
        if (isSchedulerEnable.startDateTime.isBefore(DateTime.now())) {
          if (isSchedulerEnable.enableJob == true) {
            final Response response = await api.getPreference();
            Map<String, dynamic> map = json.decode(response.bodyString);
            if (response.isSuccessful && map['success']) {
              Map<String, dynamic> result = map['result'];

              //https://github.com/simolus3/moor/issues/40
              //https://github.com/simolus3/moor/issues/20

              var items = (result['items'] as List).map((e) {
                return PreferenceData.fromJson(e,
                    serializer: CustomSerializer());
              });

              for (var item in items) {
                //var getData = PreferenceData.fromJson(item);
                await preferenceDao.createOrUpdatePref(item);
              }

              await updateBackgroundJobStatus.updateJobStatus(
                  jobName, "Success");
            } else {
              updateBackgroundJobStatus.updateJobStatus(jobName, "Error");
            }
          }
        }
      }
    } catch (error) {
      updateBackgroundJobStatus.updateJobStatus(jobName, "Error");
      _log.shout(error, StackTrace.current);
    }
  }

  Future<void> getNonGlobalPrefFromServer(String jobName) async {
    try {
      var isSchedulerEnable = await backgroundJobScheduleDao.getJob(jobName);
      if (isSchedulerEnable != null) {
        if (isSchedulerEnable.startDateTime.isBefore(DateTime.now())) {
          if (isSchedulerEnable.enableJob == true) {
            final Response response = await api.getNonGlobalPreference();
            Map<String, dynamic> map = json.decode(response.bodyString);
            if (response.isSuccessful && map['success']) {
              Map<String, dynamic> result = map['result'];

              //https://github.com/simolus3/moor/issues/40
              //https://github.com/simolus3/moor/issues/20

              var items = (result['items'] as List).map((e) {
                return NonGlobalPreferenceData.fromJson(e,
                    serializer: CustomSerializer());
              });

              for (var item in items) {
                //var getData = PreferenceData.fromJson(item);
                await nonGlobalPreferenceDao.createOrUpdatePref(item);
              }

              await updateBackgroundJobStatus.updateJobStatus(
                  jobName, "Success");
            } else {
              updateBackgroundJobStatus.updateJobStatus(jobName, "Error");
              _log.shout(
                  "Non-Global Prefrence Call Failed", StackTrace.current);
            }
          }
        }
      }
    } catch (e) {
      updateBackgroundJobStatus.updateJobStatus(jobName, "Error");
      _log.shout(e, StackTrace.current);
    }
  }
}
