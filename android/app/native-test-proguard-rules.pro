# Keep only the integration_test JVM result bridge for release instrumentation.
# Applied exclusively when -PnativeTestBuildType=release; notification/calendar
# plugins retain the production shrinking rules exercised by the regression.
-keep class dev.flutter.plugins.integration_test.** { *; }
# Instrumentation is loaded by name, and FlutterTestRunner reflects @Rule
# fields. Preserve the test harness in both APKs, without changing app adapters.
-keep class androidx.test.** { *; }
-keep class org.junit.** { *; }
-keep class app.cleartray.NativeReleaseTest { *; }

# Native icon tests call this public adapter directly in the minified APK.
-keep class app.cleartray.AppIconManager { *; }
-keep class app.cleartray.AppIconManagerTest { *; }
-keep class app.cleartray.MicrosoftTodoAuthTest { *; }
