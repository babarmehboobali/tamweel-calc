# Google Mobile Ads / UMP
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-keep class com.google.android.ump.** { *; }
-dontwarn com.google.android.gms.**
# Flutter plugins using JNI (path_provider_android/jni) look up classes by name
-keep class com.github.dart_lang.jni.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class androidx.core.** { *; }
-keep class androidx.lifecycle.** { *; }
-dontwarn com.google.android.play.core.**
