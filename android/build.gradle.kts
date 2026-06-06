allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Force every Android+Kotlin sub-module (including third-party plugins like
// receive_sharing_intent, home_widget) to compile with consistent JVM target 17.
// We register the override via afterEvaluate so it runs *after* each plugin
// configures its own compileOptions and kotlinOptions.
//
// Also patches plugins that pre-date AGP 8's namespace requirement
// (device_calendar 3.x ships an AndroidManifest with `package=` only) by
// reading that package and injecting it as the module namespace.
subprojects {
    afterEvaluate {
        extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.apply {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
            if (namespace == null) {
                val manifestFile = file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val xml = groovy.xml.XmlParser().parse(manifestFile)
                    val pkg = xml.attribute("package") as String?
                    if (pkg != null) {
                        namespace = pkg
                    }
                }
            }
            // Force compileSdk to 36 so plugins shipping with an outdated
            // value (e.g. device_calendar 3.x pins 29) build under AGP 8;
            // modern AndroidX libs (core 1.18, navigationevent) require 36+.
            compileSdkVersion(36)
        }
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = JavaVersion.VERSION_17.toString()
            targetCompatibility = JavaVersion.VERSION_17.toString()
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
