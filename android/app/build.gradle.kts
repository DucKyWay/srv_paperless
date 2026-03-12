import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.srv_paperless"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
        }
    }

    defaultConfig {
        applicationId = "com.example.srv_paperless"

        // โหลดไฟล์ .env
        val env = Properties()
        val envFile = project.rootProject.file("../.env")
        
        if (envFile.exists()) {
            FileInputStream(envFile).use { env.load(it) }
            println("SRV Debug: .env file found at ${envFile.absolutePath}")
        } else {
            println("SRV Debug: .env file NOT FOUND at ${envFile.absolutePath}")
        }
        
        val mapsApiKey = env.getProperty("GOOGLE_MAP_API_KEY") 
                        ?: env.getProperty("API_KEY_GOOGLE_MAP") 
                        ?: ""
        
        if (mapsApiKey.isEmpty()) {
            println("SRV Debug: GOOGLE_MAP_API_KEY is empty!")
        } else {
            println("SRV Debug: GOOGLE_MAP_API_KEY loaded successfully")
        }
        
        manifestPlaceholders["GOOGLE_MAP_API_KEY"] = mapsApiKey

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
