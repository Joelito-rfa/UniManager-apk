# Flutter engine
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Flutter plugins (auto-generated)
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# flutter_secure_storage + AndroidKeyStore
-keep class com.cyberowl.flutter_secure_storage.** { *; }
-keep class android.security.keystore.** { *; }
-keep class android.security.** { *; }
-keep class javax.crypto.** { *; }
-keep class java.security.** { *; }
-keep class android.app.admin.** { *; }
-dontwarn com.cyberowl.flutter_secure_storage.**

# permission_handler
-keep class com.permission_handler.** { *; }
-dontwarn com.permission_handler.**

# flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# file_picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-dontwarn com.mr.flutter.plugin.filepicker.**

# image_picker
-keep class io.flutter.plugins.imagepicker.** { *; }
-dontwarn io.flutter.plugins.imagepicker.**

# connectivity_plus, network_info_plus, device_info_plus, package_info_plus
-keep class dev.fluttercommunity.plus.** { *; }
-dontwarn dev.fluttercommunity.plus.**

# shared_preferences_android
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**

# path_provider_android
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn io.flutter.plugins.pathprovider.**

# sqflite
-keep class com.tencent.wcdb.** { *; }
-dontwarn com.tencent.wcdb.**

# open_file
-keep class com.rzaiats.openfile.** { *; }
-dontwarn com.rzaiats.openfile.**

# Android general
-keep class * extends android.app.Activity { *; }
-keep class * extends android.app.Application { *; }
-keep class * extends android.app.Service { *; }
-keep class * extends android.content.BroadcastReceiver { *; }
-keep class * implements android.os.Parcelable { *; }

# Keep R8 from stripping generic signatures
-keepattributes Signature
-keepattributes *Annotation*

# Keep JSON serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keep @com.google.gson.annotations.Expose class * { *; }

# Remove debug logging in release
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
    public static int i(...);
}
