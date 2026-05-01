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
        if (project.hasProperty("android")) {
            val androidExt = project.extensions.findByName("android")
            if (androidExt != null) {
                try {
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
