buildscript {
    repositories {
        google()
        mavenCentral()
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        kotlinOptions {
            jvmTarget = "17"
        }
    }
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }

    afterEvaluate {
        if (project.hasProperty("android")) {
            val androidExt = project.extensions.findByName("android")
            if (androidExt != null) {
                try {
                    // Force compile options to 17
                    val compileOptions = androidExt.javaClass.methods.find { it.name == "getCompileOptions" }?.invoke(androidExt)
                    if (compileOptions != null) {
                        compileOptions.javaClass.methods.find { it.name == "setSourceCompatibility" && it.parameterTypes.size == 1 }?.invoke(compileOptions, JavaVersion.VERSION_17)
                        compileOptions.javaClass.methods.find { it.name == "setTargetCompatibility" && it.parameterTypes.size == 1 }?.invoke(compileOptions, JavaVersion.VERSION_17)
                    }

                    val getNamespaceMethod = androidExt.javaClass.methods.find { it.name == "getNamespace" }
                    val setNamespaceMethod = androidExt.javaClass.methods.find { it.name == "setNamespace" && it.parameterTypes.size == 1 && it.parameterTypes[0] == String::class.java }
                    
                    if (getNamespaceMethod != null && setNamespaceMethod != null) {
                        val currentNamespace = getNamespaceMethod.invoke(androidExt)
                        if (currentNamespace == null) {
                            val manifestFile = project.file("src/main/AndroidManifest.xml")
                            if (manifestFile.exists()) {
                                val text = manifestFile.readText()
                                val matcher = java.util.regex.Pattern.compile("package=\"(.*?)\"").matcher(text)
                                if (matcher.find()) {
                                    val foundNamespace = matcher.group(1)
                                    setNamespaceMethod.invoke(androidExt, foundNamespace)
                                }
                            }
                        }
                    }
                } catch (e: Exception) {
                    // Fail silently
                }
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
