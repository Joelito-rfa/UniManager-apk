class AppConstants {
  AppConstants._();

  static const String adminRole = 'admin';
  static const String teacherRole = 'teacher';
  static const String studentRole = 'student';

  static const String statusActive = 'active';
  static const String statusInactive = 'inactive';
  static const String statusSuspended = 'suspended';
  static const String statusGraduated = 'graduated';

  static const String gradeTypeExam = 'exam';
  static const String gradeTypeMidterm = 'midterm';
  static const String gradeTypeQuiz = 'quiz';
  static const String gradeTypeHomework = 'homework';
  static const String gradeTypeProject = 'project';

  static const String gradeValueA = 'A';
  static const String gradeValueB = 'B';
  static const String gradeValueC = 'C';
  static const String gradeValueD = 'D';
  static const String gradeValueF = 'F';

  static const String dayMonday = 'Lundi';
  static const String dayTuesday = 'Mardi';
  static const String dayWednesday = 'Mercredi';
  static const String dayThursday = 'Jeudi';
  static const String dayFriday = 'Vendredi';
  static const String daySaturday = 'Samedi';
  static const String daySunday = 'Dimanche';

  static const List<String> weekDays = [
    dayMonday, dayTuesday, dayWednesday, dayThursday, dayFriday, daySaturday, daySunday,
  ];

  static const String sessionMorning = 'matin';
  static const String sessionAfternoon = 'après-midi';
  static const String sessionEvening = 'soir';

  static const String notificationTypeInfo = 'info';
  static const String notificationTypeWarning = 'warning';
  static const String notificationTypeError = 'error';
  static const String notificationTypeSuccess = 'success';

  static const int defaultPageSize = 10;
  static const int maxFileSize = 5 * 1024 * 1024;

  static const String dateFormatDisplay = 'dd/MM/yyyy';
  static const String dateFormatApi = 'yyyy-MM-dd';
  static const String dateTimeFormatDisplay = 'dd/MM/yyyy HH:mm';
  static const String timeFormatDisplay = 'HH:mm';
}
