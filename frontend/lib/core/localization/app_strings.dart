import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/preferences_provider.dart';

class AppStrings {
  final String search;
  final String notifications;
  final String messages;
  final String profile;
  final String myProfile;
  final String editProfile;
  final String preferences;
  final String changePassword;
  final String logout;
  final String contactUs;
  final String theme;
  final String language;
  final String serverStatus;
  final String connectionStatus;
  final String backup;
  final String lastBackup;
  final String backupNow;
  final String newItem;
  final String addStudent;
  final String addTeacher;
  final String addDepartment;
  final String addProgram;
  final String addSubject;
  final String addClassroom;
  final String addCourse;
  final String addSchedule;
  final String addEnrollment;
  final String addGrade;
  final String addAssignment;
  final String addResource;
  final String online;
  final String offline;
  final String operational;
  final String maintenance;
  final String downtime;
  final String loading;
  final String noResults;
  final String markAllRead;
  final String deleteAll;
  final String noNotifications;
  final String noMessages;
  final String monday;
  final String tuesday;
  final String wednesday;
  final String thursday;
  final String friday;
  final String saturday;
  final String sunday;
  final String january;
  final String february;
  final String march;
  final String april;
  final String may;
  final String june;
  final String july;
  final String august;
  final String september;
  final String october;
  final String november;
  final String december;

  const AppStrings({
    required this.search,
    required this.notifications,
    required this.messages,
    required this.profile,
    required this.myProfile,
    required this.editProfile,
    required this.preferences,
    required this.changePassword,
    required this.logout,
    required this.contactUs,
    required this.theme,
    required this.language,
    required this.serverStatus,
    required this.connectionStatus,
    required this.backup,
    required this.lastBackup,
    required this.backupNow,
    required this.newItem,
    required this.addStudent,
    required this.addTeacher,
    required this.addDepartment,
    required this.addProgram,
    required this.addSubject,
    required this.addClassroom,
    required this.addCourse,
    required this.addSchedule,
    required this.addEnrollment,
    required this.addGrade,
    required this.addAssignment,
    required this.addResource,
    required this.online,
    required this.offline,
    required this.operational,
    required this.maintenance,
    required this.downtime,
    required this.loading,
    required this.noResults,
    required this.markAllRead,
    required this.deleteAll,
    required this.noNotifications,
    required this.noMessages,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
    required this.january,
    required this.february,
    required this.march,
    required this.april,
    required this.may,
    required this.june,
    required this.july,
    required this.august,
    required this.september,
    required this.october,
    required this.november,
    required this.december,
  });
}

final appStringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(languageProvider);
  switch (lang) {
    case 'en':
      return AppStrings(
        search: 'Search',
        notifications: 'Notifications',
        messages: 'Messages',
        profile: 'Profile',
        myProfile: 'My Profile',
        editProfile: 'Edit Profile',
        preferences: 'Preferences',
        changePassword: 'Change Password',
        logout: 'Logout',
        contactUs: 'Contact Us',
        theme: 'Theme',
        language: 'Language',
        serverStatus: 'Server Status',
        connectionStatus: 'Connection Status',
        backup: 'Backup',
        lastBackup: 'Last backup',
        backupNow: 'Backup Now',
        newItem: 'New',
        addStudent: 'Add Student',
        addTeacher: 'Add Teacher',
        addDepartment: 'Add Department',
        addProgram: 'Add Program',
        addSubject: 'Add Subject',
        addClassroom: 'Add Classroom',
        addCourse: 'Add Course',
        addSchedule: 'Add Schedule',
        addEnrollment: 'Add Enrollment',
        addGrade: 'Add Grade',
        addAssignment: 'Add Assignment',
        addResource: 'Add Resource',
        online: 'Online',
        offline: 'Offline',
        operational: 'Operational',
        maintenance: 'Maintenance',
        downtime: 'Down',
        loading: 'Loading...',
        noResults: 'No results',
        markAllRead: 'Mark all as read',
        deleteAll: 'Delete all',
        noNotifications: 'No notifications',
        noMessages: 'No messages',
        monday: 'Monday', tuesday: 'Tuesday', wednesday: 'Wednesday',
        thursday: 'Thursday', friday: 'Friday', saturday: 'Saturday', sunday: 'Sunday',
        january: 'January', february: 'February', march: 'March', april: 'April',
        may: 'May', june: 'June', july: 'July', august: 'August',
        september: 'September', october: 'October', november: 'November', december: 'December',
      );
    case 'mg':
      return AppStrings(
        search: 'Fikarohana',
        notifications: 'Fampandrenesana',
        messages: 'Hafatra',
        profile: 'Momba anao',
        myProfile: 'Momba anao',
        editProfile: 'Hanova momba anao',
        preferences: 'Safidy',
        changePassword: 'Hanova tenimiafina',
        logout: 'Hivoaka',
        contactUs: 'Hifandray',
        theme: 'Loko',
        language: 'Fiteny',
        serverStatus: 'Sata mpizara',
        connectionStatus: 'Sata fifandraisana',
        backup: 'Tahiry',
        lastBackup: 'Tahiry farany',
        backupNow: 'Tehirizo izao',
        newItem: 'Vaovao',
        addStudent: 'Hanampy mpianatra',
        addTeacher: 'Hanampy mpampianatra',
        addDepartment: 'Hanampy sampana',
        addProgram: 'Hanampy fandaharana',
        addSubject: 'Hanampy lohahevitra',
        addClassroom: 'Hanampy efitrano',
        addCourse: 'Hanampy fampianarana',
        addSchedule: 'Hanampy fandaharam-potoana',
        addEnrollment: 'Hanampy fisoratana',
        addGrade: 'Hanampy naoty',
        addAssignment: 'Hanampy asa',
        addResource: 'Hanampy fitaovana',
        online: 'An-tserasera',
        offline: 'Tsy an-tserasera',
        operational: 'Miasa',
        maintenance: 'Fikojakojana',
        downtime: 'Tsy miasa',
        loading: 'Mampiditra...',
        noResults: 'Tsy misy valiny',
        markAllRead: 'Vakio daholo',
        deleteAll: 'Fafao daholo',
        noNotifications: 'Tsy misy fampandrenesana',
        noMessages: 'Tsy misy hafatra',
        monday: 'Alatsinainy', tuesday: 'Talata', wednesday: 'Alarobia',
        thursday: 'Alakamisy', friday: 'Zoma', saturday: 'Asabotsy', sunday: 'Alahady',
        january: 'Janoary', february: 'Febroary', march: 'Martsa', april: 'Aprily',
        may: 'Mey', june: 'Jona', july: 'Jolay', august: 'Aogositra',
        september: 'Septambra', october: 'Oktobra', november: 'Novambra', december: 'Desambra',
      );
    default:
      return AppStrings(
        search: 'Rechercher',
        notifications: 'Notifications',
        messages: 'Messages',
        profile: 'Profil',
        myProfile: 'Mon profil',
        editProfile: 'Modifier le profil',
        preferences: 'Préférences',
        changePassword: 'Changer le mot de passe',
        logout: 'Déconnexion',
        contactUs: 'Nous contacter',
        theme: 'Thème',
        language: 'Langue',
        serverStatus: 'État serveur',
        connectionStatus: 'Connexion',
        backup: 'Sauvegarde',
        lastBackup: 'Dernière sauvegarde',
        backupNow: 'Sauvegarder maintenant',
        newItem: 'Nouveau',
        addStudent: 'Ajouter étudiant',
        addTeacher: 'Ajouter enseignant',
        addDepartment: 'Ajouter département',
        addProgram: 'Ajouter filière',
        addSubject: 'Ajouter matière',
        addClassroom: 'Ajouter salle',
        addCourse: 'Ajouter cours',
        addSchedule: 'Ajouter emploi du temps',
        addEnrollment: 'Ajouter inscription',
        addGrade: 'Ajouter note',
        addAssignment: 'Ajouter devoir',
        addResource: 'Ajouter support de cours',
        online: 'En ligne',
        offline: 'Hors ligne',
        operational: 'Opérationnel',
        maintenance: 'Maintenance',
        downtime: 'Hors service',
        loading: 'Chargement...',
        noResults: 'Aucun résultat',
        markAllRead: 'Tout marquer comme lu',
        deleteAll: 'Tout supprimer',
        noNotifications: 'Aucune notification',
        noMessages: 'Aucun message',
        monday: 'Lundi', tuesday: 'Mardi', wednesday: 'Mercredi',
        thursday: 'Jeudi', friday: 'Vendredi', saturday: 'Samedi', sunday: 'Dimanche',
        january: 'Janvier', february: 'Février', march: 'Mars', april: 'Avril',
        may: 'Mai', june: 'Juin', july: 'Juillet', august: 'Août',
        september: 'Septembre', october: 'Octobre', november: 'Novembre', december: 'Décembre',
      );
  }
});

// languageProvider is now in providers/preferences_provider.dart
