import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing — credentials live in android/key.properties (gitignored).
// See android/RELEASE_SIGNING.md for setup. Falls back to debug signing if the
// file is missing (so contributors without the keystore can still build).
val keystoreProperties = Properties().apply {
    val keystoreFile = rootProject.file("key.properties")
    if (keystoreFile.exists()) {
        load(FileInputStream(keystoreFile))
    }
}

android {
    namespace = "app.cleartray"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications requires core library desugaring.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "app.cleartray"
        // flutter_local_notifications + permission_handler need 21+; we bump to 23 for safety.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        // Launcher / widget-picker name. Overridden per build type so the
        // debug build is distinguishable from the internal-testing release
        // when both are installed side by side.
        manifestPlaceholders["appLabel"] = "Trayzero"
    }

    signingConfigs {
        create("release") {
            val storePath = keystoreProperties["storeFile"] as String?
            if (storePath != null) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(storePath)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        debug {
            // Distinct package so the debug build coexists with the
            // internal-testing release (app.cleartray) on one device, with a
            // fully separate data sandbox and independent uninstall.
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
            manifestPlaceholders["appLabel"] = "Trayzero Debug"
        }
        release {
            // Use release keystore when key.properties exists, else fall back to
            // debug so contributors without the keystore can still build.
            signingConfig = if (keystoreProperties.containsKey("storeFile")) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }

    // F-Droid only: drop AGP's Google "Dependency Info" block so F-Droid's
    // source scanner passes. Gated on -Pfdroid; ABSENT by default so Play (AAB)
    // and App Store builds keep AGP defaults (true/true) and are byte-identical.
    dependenciesInfo {
        includeInApk = !project.hasProperty("fdroid")
        includeInBundle = !project.hasProperty("fdroid")
    }

    // Per-ABI split builds (`flutter build apk --split-per-abi`, used by F-Droid)
    // embed versionCode * 10 + {1,2,3} so each ABI gets a distinct, ordered code.
    // Outputs without an ABI filter — the universal APK and the Play AAB — have
    // no matching filter here, so they keep the plain versionCode untouched.
    // Uses the legacy variant API: the modern androidComponents.onVariants hook
    // runs before Flutter's split versionCode composition and loses to it.
    applicationVariants.configureEach {
        val variant = this
        outputs.forEach { output ->
            val abiCode = mapOf("armeabi-v7a" to 1, "arm64-v8a" to 2, "x86_64" to 3)[
                output.filters.find { it.filterType == "ABI" }?.identifier
            ]
            if (abiCode != null) {
                (output as com.android.build.gradle.internal.api.ApkVariantOutputImpl)
                    .versionCodeOverride = variant.versionCode * 10 + abiCode
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
