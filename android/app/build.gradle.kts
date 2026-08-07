import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

// تحميل بيانات توقيع الإصدار من key.properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

val hasKeystoreProperties = keystorePropertiesFile.exists()

if (hasKeystoreProperties) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.yusufnaser.customsbroker"

    // رفعه لأن بعض الإضافات الحديثة تحتاج Android API 36
    compileSdk = 36

    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.yusufnaser.customsbroker"

        minSdk = flutter.minSdkVersion

        // مناسب للنشر الحالي
        targetSdk = 36

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {

        if (hasKeystoreProperties) {

            create("release") {

                keyAlias =
                    keystoreProperties["keyAlias"] as String

                keyPassword =
                    keystoreProperties["keyPassword"] as String

                storeFile =
                    file(keystoreProperties["storeFile"] as String)

                storePassword =
                    keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {

        release {

            signingConfig =
                if (hasKeystoreProperties) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }

            // تحسين حجم الإصدار
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

kotlin {

    compilerOptions {

        jvmTarget =
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
