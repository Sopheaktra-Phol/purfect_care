plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.purfect_care"
    compileSdk = 34 // Or flutter.compileSdkVersion if using Flutter constants
    ndkVersion = "25.1.8937393" // Or flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.purfect_care"
        minSdk = flutter.minSdkVersion // Must be 21+ for flutter_local_notifications
        targetSdk = 34 // Or flutter.targetSdkVersion
        versionCode = 1
        versionName = "0.1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            // Optimize debug builds
            isMinifyEnabled = false
            isDebuggable = true
        }
    }
    
    // Build performance optimizations
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }
}

dependencies {
    // Core library desugaring for flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}

flutter {
    source = "../.."
}
