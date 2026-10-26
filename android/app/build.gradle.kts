import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.isFile) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}
val releaseApplicationId = providers.gradleProperty("applicationId")
    .getOrElse("com.example.authentication")

android {
    namespace = "com.example.authentication"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Set applicationId in android/gradle.properties or through
        // ORG_GRADLE_PROJECT_applicationId before creating the Play listing.
        applicationId = releaseApplicationId
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storePassword = keystoreProperties.getProperty("storePassword")
            storeFile = keystoreProperties.getProperty("storeFile")
                ?.takeIf { it.isNotBlank() }
                ?.let { rootProject.file(it) }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

val validateReleaseConfiguration = tasks.register("validateReleaseConfiguration") {
    doLast {
        check(!releaseApplicationId.startsWith("com.example.")) {
            "Set your permanent Play package ID with applicationId in " +
                "android/gradle.properties or ORG_GRADLE_PROJECT_applicationId."
        }
        check(keystorePropertiesFile.isFile) {
            "Release signing is required. For an existing Play upload key, configure " +
                "android/key.properties using android/key.properties.example. " +
                "To create a new upload key, run python3 scripts/setup_android_signing.py " +
                "from the project root."
        }
        val missing = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
            .filter { keystoreProperties.getProperty(it).isNullOrBlank() }
        check(missing.isEmpty()) {
            "Missing release signing properties in android/key.properties: ${missing.joinToString()}."
        }
        check(rootProject.file(keystoreProperties.getProperty("storeFile")).isFile) {
            "Upload keystore not found. Check storeFile in android/key.properties."
        }
    }
}

tasks.configureEach {
    if (name == "preReleaseBuild" || name == "validateSigningRelease") {
        dependsOn(validateReleaseConfiguration)
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
