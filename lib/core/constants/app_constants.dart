/// ─────────────────────────────────────────────────────────────
/// AgroLink — Application Constants
/// ─────────────────────────────────────────────────────────────

class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────────────────
  static const String appName = 'AgroLink';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Smart Agriculture Consultation';

  // ── Firestore Collections ─────────────────────────────────
  static const String usersCollection = 'users';
  static const String farmersCollection = 'farmers';
  static const String plotsCollection = 'plots';
  static const String visitsCollection = 'visits';
  static const String routesCollection = 'routes';
  static const String notificationsCollection = 'notifications';
  static const String analyticsCollection = 'analytics';

  // ── Storage Paths ─────────────────────────────────────────
  static const String profileImagesPath = 'profile_images';
  static const String plotImagesPath = 'plot_images';
  static const String visitImagesPath = 'visit_images';
  static const String diseaseImagesPath = 'disease_images';

  // ── User Roles ────────────────────────────────────────────
  static const String roleAdmin = 'admin';
  static const String roleDoctor = 'doctor';
  static const String roleFarmer = 'farmer';
  static const String roleDriver = 'driver';

  // ── Severity Levels ───────────────────────────────────────
  static const String severityCritical = 'critical';
  static const String severityHigh = 'high';
  static const String severityMedium = 'medium';
  static const String severityLow = 'low';

  // ── Priority Levels ───────────────────────────────────────
  static const String priorityUrgent = 'urgent';
  static const String priorityHigh = 'high';
  static const String priorityNormal = 'normal';
  static const String priorityLow = 'low';

  // ── Visit Status ──────────────────────────────────────────
  static const String visitScheduled = 'scheduled';
  static const String visitInProgress = 'in_progress';
  static const String visitCompleted = 'completed';
  static const String visitCancelled = 'cancelled';
  static const String visitMissed = 'missed';

  // ── Disease Status ────────────────────────────────────────
  static const String diseaseActive = 'active';
  static const String diseaseRecovering = 'recovering';
  static const String diseaseResolved = 'resolved';

  // ── Crop Types ────────────────────────────────────────────
  static const List<String> cropTypes = [
    'Pomegranate',
    'Grape',
    'Mango',
    'Banana',
    'Cotton',
    'Sugarcane',
    'Soybean',
    'Onion',
    'Tomato',
    'Other',
  ];

  // ── Common Diseases (Pomegranate) ─────────────────────────
  static const List<String> commonDiseases = [
    'Bacterial Blight',
    'Wilt',
    'Anthracnose',
    'Cercospora Fruit Spot',
    'Alternaria Fruit Rot',
    'Phytophthora Blight',
    'Powdery Mildew',
    'Leaf Spot',
    'Fruit Borer',
    'Aphids',
    'Mealybug',
    'Thrips',
    'Mites',
    'Root Rot',
    'Stem Canker',
    'Other',
  ];

  // ── Notification Types ────────────────────────────────────
  static const String notifVisitReminder = 'visit_reminder';
  static const String notifFollowUp = 'follow_up';
  static const String notifMissedVisit = 'missed_visit';
  static const String notifCriticalAlert = 'critical_alert';
  static const String notifGeneral = 'general';

  // ── Pagination ────────────────────────────────────────────
  static const int pageSize = 20;
  static const int searchDebounceMs = 500;

  // ── Image Constraints ─────────────────────────────────────
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const int imageQuality = 80;
  static const int maxImagesPerUpload = 10;
  static const int maxFileSizeMb = 5;
}
