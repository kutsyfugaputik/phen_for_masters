class MasterModel {
  final String masterId;
  final String userId;
  final String specialization;
  final int tgUid;
  final int yearsOfExperience;
  final String? workExamples;

  MasterModel({
    required this.masterId,
    required this.userId,
    required this.specialization,
    required this.tgUid,
    required this.yearsOfExperience,
    this.workExamples,
  });

  factory MasterModel.fromJson(Map<String, dynamic> json) => MasterModel(
    masterId: json['master_id'],
    userId: json['user_id'],
    specialization: json['specialization'],
    tgUid: json['tg_uid'],
    yearsOfExperience: json['years_of_experience'],
    workExamples: json['work_examples'],
  );

  Map<String, dynamic> toJson() => {
    'master_id': masterId,
    'user_id': userId,
    'specialization': specialization,
    'tg_uid': tgUid,
    'years_of_experience': yearsOfExperience,
    'work_examples': workExamples,
  };
}
