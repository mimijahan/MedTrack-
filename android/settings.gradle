// android/settings.gradle.kts

pluginManagement {
    // 1. Define flutterSdkPath locally using a run block to ensure scope is valid
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        // 'file' is available in the settings context
        file("local.properties").inputStream().use { properties.load(it) }
        val path = properties.getProperty("flutter.sdk")
        require(path != null) { "flutter.sdk not set in local.properties" }
        path
    }

    // 2. Include the Flutter tools build
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        // 3. CRITICAL FIX: Replaced 'projectDir' with 'settingsDir.parentFile'
        maven { url = uri("${settingsDir.parentFile.absolutePath}/.flutter/build/outputs/repo") }
    }
}

// 4. CRITICAL FIX (Original Issue): Explicitly include the 'app' module
include(":app")