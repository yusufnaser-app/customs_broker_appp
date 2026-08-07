import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

val hasKeystoreProperties = keystorePropertiesFile.exists()

if (hasKeystoreProperties) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {

    namespace = "com.yusufnaser.customsbroker"

    // تحديث مهم لحل مشكلة file_picker و lifecycle
    compileSdk = 36

    ndkVersion = flutter.ndkVersion


    compileOptions {

        sourceCompatibility = JavaVersion.VERSION_17

        targetCompatibility = JavaVersion.VERSION_17

    }


    defaultConfig {

        applicationId = "com.yusufnaser.customsbroker"

        minSdk = flutter.minSdkVersion

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
                    file(
                        keystoreProperties["storeFile"] as String
                    )

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


            // لتقليل مشاكل Gradle أثناء الإصدار

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
