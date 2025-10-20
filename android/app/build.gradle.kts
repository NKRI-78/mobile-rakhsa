import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    
    // id("com.google.gms.google-services")
}

// def localProperties = new Properties()
// def localPropertiesFile = rootProject.file('local.properties')
// if (localPropertiesFile.exists()) {
//     localPropertiesFile.withReader('UTF-8') { reader ->
//         localProperties.load(reader)
//     }
// }

// def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
// if (flutterVersionCode == null) {
//     flutterVersionCode = '1'
// }

// def flutterVersionName = localProperties.getProperty('flutter.versionName')
// if (flutterVersionName == null) {
//     flutterVersionName = '1.0'
// }

// def keystoreProperties = new Properties()
// def keystorePropertiesFile = rootProject.file('key.properties')
// if (keystorePropertiesFile.exists()) {
//     keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
// }

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.inovatiftujuh8.rakhsa"
    // compileSdk = 34
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // sourceCompatibility JavaVersion.VERSION_1_8
        // targetCompatibility JavaVersion.VERSION_1_8
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        // jvmTarget = '1.8'
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // sourceSets {
    //     main.java.srcDirs += 'src/main/kotlin'
    // }

    defaultConfig {
        // applicationId "com.inovatiftujuh8.rakhsa"
        // minSdkVersion 23
        // targetSdkVersion 34
        // versionCode flutterVersionCode.toInteger()
        // versionName flutterVersionName
        
        applicationId = "com.inovatiftujuh8.rakhsa"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // signingConfigs {
    //     release {
    //         keyAlias keystoreProperties['keyAlias']
    //         keyPassword keystoreProperties['keyPassword']
    //         storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
    //         storePassword keystoreProperties['storePassword']
    //     }
    // }
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            // signingConfig signingConfigs.release
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

// dependencies {
//     implementation "com.google.android.gms:play-services-location:21.0.0"
//     implementation "io.github.sangcomz:fishbun:1.1.1"
//     implementation "com.google.firebase:firebase-bom:31.2.3"
// }