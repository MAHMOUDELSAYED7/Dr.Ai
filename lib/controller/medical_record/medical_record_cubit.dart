import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dr_ai/core/utils/constant/api_url.dart';
import 'package:equatable/equatable.dart';

part 'medical_record_state.dart';

class MedicalRecordCubit extends Cubit<MedicalRecordState> {
  MedicalRecordCubit() : super(MedicalRecordState.initial());

  static String defaultId = EnvManager.defaultMedicalRecordID;

  String get baseUrl => EnvManager.medicalRecord;
  String? nfcID;

  String get initialUrl => EnvManager.medicalRecord;

  void initWebView() {
    emit(state.copyWith(url: '${EnvManager.medicalRecord}$defaultId'));
  }

  void updateWebViewId(String id) {
    if (id.isNotEmpty) {
      log("ANA EL ID: $id");
      emit(state.copyWith(url: '${EnvManager.medicalRecord}$id'));
    } else {
      emit(state.copyWith(url: '${EnvManager.medicalRecord}$defaultId'));
    }
  }
}
