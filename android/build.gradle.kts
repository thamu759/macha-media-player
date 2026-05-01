buildscript {
    repositories {
        google()
        mavenCentral()
    }
    rootProject.extra["ffmpegKitPackage"] = "audio"
    rootProject.extra["ffmpegKitVersion"] = "4.5.LTS"
}

allprojects {
    repositories {
        google()
        mavenCentral()
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
    
    afterEvaluate {
        if (name == "on_audio_query_android") {
            try {
                val androidExt = extensions.getByName("android")
                androidExt.javaClass.getMethod("setNamespace", String::class.java).invoke(androidExt, "com.lucasjosino.on_audio_query")
            } catch (e: Exception) {
                println("Failed to set namespace for on_audio_query_android: ${e.message}")
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
