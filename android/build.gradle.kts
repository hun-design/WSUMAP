// Top-level build file where you can add configuration options common to all sub-projects/modules.
// Flutter는 settings.gradle.kts에서 플러그인 버전을 관리하므로 여기서는 제거합니다.

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 모든 서브프로젝트에 compileSdk 버전 강제 설정 (flutter_compass lStar 속성 지원)
subprojects {
    afterEvaluate {
        extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
            compileSdkVersion(35)
            // minifyEnabled가 false일 때 shrinkResources도 비활성화
            buildTypes?.forEach { buildType ->
                if (buildType.isMinifyEnabled == false) {
                    buildType.isShrinkResources = false
                }
            }
        }
    }
}

rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
