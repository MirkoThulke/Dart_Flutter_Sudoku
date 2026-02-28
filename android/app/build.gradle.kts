plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream
import org.gradle.api.GradleException

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

if (!keystorePropertiesFile.exists()) {
    throw GradleException("❌ key.properties not found! Release signing cannot continue.")
}

keystoreProperties.load(FileInputStream(keystorePropertiesFile))

android {
    namespace = "com.mtulli.sudoku"
    // Align version with dockerfile internal version !!!
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.mtulli.sudoku"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.

        // Align version with dockerfile internal version !!!
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.1"
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
        }
    }
    
}

flutter {
    source = "../.."
}
