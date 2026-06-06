# R8/ProGuard keep rules for the RELEASE build.
#
# Flutter enables code shrinking (R8) for the `release` build type by default
# (flutter_tools FlutterPlugin sets `isMinifyEnabled = true`), and the
# internal-testing AAB is built with `flutter build appbundle --release`.
# `flutter build apk/run --debug` does NOT run R8, which is why this bug is
# invisible in debug and only bites the Play / internal-testing build.
#
# flutter_local_notifications (18.x) persists scheduled notifications with
# Gson, deserialising them via:
#
#   new TypeToken<ArrayList<NotificationDetails>>() {}.getType()
#
# in loadScheduledNotifications(), which runs on every zonedSchedule(),
# cancel(), pendingNotificationRequests(), AND in ScheduledNotificationBoot-
# Receiver on BOOT_COMPLETED / MY_PACKAGE_REPLACED (i.e. every app update).
# Without `-keepattributes Signature`, R8 strips the generic type argument
# and that call throws at runtime:
#
#   java.lang.RuntimeException: Missing type parameter.
#
# Net effect before this file existed: scheduled reminders silently failed in
# release, and the boot/update receiver crashed so reminders were never
# re-armed after an internal-testing update. The plugin ships NO consumer
# ProGuard rules, so the host app must supply them (flutter_local_notifications
# README, "Android setup": "If you fail to do this, notifications might be
# broken. In the worst case they will never show, instead silently failing").
#
# Gson block mirrors the canonical upstream config:
#   https://github.com/google/gson/blob/main/examples/android-proguard-example/proguard.cfg

# Gson stores field/type generics in the class-file Signature attribute and
# reads them via reflection. R8 removes it by default — keep it. THIS line is
# the actual fix for "Missing type parameter".
-keepattributes Signature
# @SerializedName / @Expose and friends.
-keepattributes *Annotation*
-keepattributes EnclosingMethod,InnerClasses

-dontwarn sun.misc.**

# Don't strip the interface info off Gson (de)serialisers / factories.
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep @SerializedName-annotated fields from being renamed to null-mapped.
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Retain generic signatures of TypeToken & subclasses (R8 full mode, 3.0+).
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# flutter_local_notifications model graph is (de)serialised by Gson by field
# name (NotificationDetails, the StyleInformation subtypes wired through a
# RuntimeTypeAdapterFactory, and ScheduleMode.Deserializer). Renaming or
# pruning any of it breaks JSON round-tripping — keep the whole package.
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**
