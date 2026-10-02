# Flutter Wrapper & Plugins
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-keep class * extends io.flutter.embedding.android.FlutterActivity { *; }

# Application Packages
-keep class com.luminclash.** { *; }

# Dart JNI & Android Plugins
-keep class com.github.dart_lang.** { *; }
-dontwarn com.github.dart_lang.**
-keep class androidx.window.** { *; }

# JNI & FFI Native Library bindings
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep CGO exported dynamic symbols and runtime reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
