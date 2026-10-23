allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = file("${System.getProperty("user.home")}/.flutter_build/weather_forecast_app")
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    project.layout.buildDirectory.set(newBuildDir.resolve(project.name))
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    fun updateSdk(p: Project) {
        val android = p.extensions.findByName("android")
        if (android != null) {
            try {
                val method = android.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                method.invoke(android, 36)
            } catch (e: Exception) {
                try {
                    val method = android.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                    method.invoke(android, 36)
                } catch (e: Exception) {
                    try {
                        val method = android.javaClass.getMethod("setCompileSdk", java.lang.Integer::class.java)
                        method.invoke(android, 36)
                    } catch (e: Exception) {}
                }
            }
        }
    }

    if (project.state.executed) {
        updateSdk(project)
    } else {
        project.afterEvaluate {
            updateSdk(project)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

