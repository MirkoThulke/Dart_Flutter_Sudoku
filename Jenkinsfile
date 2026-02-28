//  ------------------------------------------------------------
//  ------------------------------------------------------------
//  RUN THE JENKINS CONTAINER — STEP 1/4
//
//  Prepare HOST directories (persistent)
//
//  sudo mkdir -p /home/mirko/jenkins_host_home
//  sudo chown -R 2000:2000 /home/mirko/jenkins_host_home
//  sudo chmod -R 770 /home/mirko/jenkins_host_home
//
//  sudo mkdir -p /home/mirko/jenkins_host_cache/gradle
//  sudo mkdir -p /home/mirko/jenkins_host_cache/pub
//  sudo mkdir -p /home/mirko/jenkins_host_cache/cargo
//  sudo chown -R 2000:2000 /home/mirko/jenkins_host_cache
//  sudo chmod -R 770 /home/mirko/jenkins_host_cache


// Start the Jenkins Docker container via : compose build via your compose.yaml file
//     docker compose up -d --build
//     docker compose up -d --build --pull=never
//     docker compose down
//     docker compose logs -f
//     docker compose ps
//
//  Check ownership and permissions of the Jenkins workspace:
//   ls -ld /home/mirko/jenkins_home_host_mount
//  ------------------------------------------------------------

//  ------------------------------------------------------------
// RUN THE JENINS CONTAINER !! STEP 2/4
//  ------------------------------------------------------------
//   Enter the jenkins container shell:
//     cd jenkins
//     docker exec -it jenkins_sudoku_container bash
//  ------------------------------------------------------------

//  ------------------------------------------------------------
//  RUN THE JENKINS CONTAINER — STEP 3/4
//
//  Print initial admin password:
//
//  cat /var/jenkins_home/secrets/initialAdminPassword
//  exit
//
//  ------------------------------------------------------------


//  ------------------------------------------------------------
//  RUN THE JENKINS CONTAINER — STEP 4/4
//  ------------------------------------------------------------
//
//  Open Jenkins UI:
//    http://localhost:8080
//
//  Configure Pipeline Job:
//
//  - Select "Pipeline"
//  - Configure GitHub repository
//  - Jenkins will CHECK OUT SOURCE CODE
//    into its dynamic workspace
//  - Select path to Jenkinsfile
//
//  IMPORTANT:
//  - Source code lives in Jenkins workspace at runtime
//  - Source code is NOT baked into any container image
//  - Build containers receive source code via bind mount
//  ------------------------------------------------------------
//  ------------------------------------------------------------

//  ------------------------------------------------------------
//  RUN THE FLUTTER CONTAINER — DEBUGGING ONLY
//  ------------------------------------------------------------
// docker run -it --rm   -v /home/mirko/jenkins_host_cache:/var/jenkins_home/workspace/Flutter_Docker_Pipeline/jenkins_container_cache   -v /home/mirko/jenkins_host_home:/var/jenkins_home/workspace/Flutter_Docker_Pipeline/jenkins_container_workspace   mirkoth/flutter_rust_env:latest   /bin/bash
// docker run -it  -v /home/mirko/jenkins_host_cache:/var/jenkins_home/workspace/Flutter_Docker_Pipeline/jenkins_container_cache   -v /home/mirko/jenkins_host_home:/var/jenkins_home/workspace/Flutter_Docker_Pipeline/jenkins_container_workspace   mirkoth/flutter_rust_env:latest   /bin/bash


//  ------------------------------------------------------------
//  CI Workflow: GitHub → Jenkins (container) → flutter_rust_env (build container)
//
//  
//  Azure VM
//   └─ docker build flutter_rust_env
//   └─ docker push flutter_rust_env (Docker Hub or GHCR)
//  
//  Local PC (WSL)
//   └─ docker pull flutter_rust_env
//   └─ Jenkins runs locally
//   └─ Builds & deploys app
//
//  CORE CONCEPTS (IMPORTANT):
//  ------------------------------------------------------------
//  - Jenkins workspaces are DYNAMIC and EPHEMERAL
//    (Flutter_Docker_Pipeline, Flutter_Docker_Pipeline@2, @3, …)
//
//  - Build caches (Gradle / Pub / Cargo) MUST be STABLE
//    and MUST NOT live under the Jenkins workspace
//
//  - Workspace = source code + build outputs (throw-away)
//  - Container HOME / CACHE = persistent caches
//
//  ------------------------------------------------------------
//  Jenkins pulls your app from GitHub into its workspace:
//
//     /var/jenkins_home/workspace/<job-name>[@N]/jenkins_container_workspace
//
//  This workspace is bind-mounted READ/WRITE into the build container:
//
//     -v $FLUTTER_CONTAINER_WORKSPACE:/sudoku_app
//
//     +---------------------------+
//     | Jenkins (Docker container)|
//     |  - UI / pipelines         |
//     |  - Job config             |
//     |  - Dynamic workspace      |
//     |    (/var/jenkins_home/    |
//     |     workspace/<job>@N)    |
//     +-------------+-------------+
//                 |
//                 | docker run
//                 v
//     +---------------------------+
//     | Flutter Build Container   |
//     |  flutter_rust_env         |
//     |  - Flutter SDK            |
//     |  - Rust toolchain         |
//     |  - Android SDK / Gradle   |
//     |  - Builds APKs / Rust libs|
//     |                           |
//     |  /sudoku_app              | ← bind-mounted from Jenkins workspace ($WORKSPACE)
//     |    └── jenkins_container_workspace/
//     |         ├── build/                    ← Flutter ephemeral build output
//     |         ├── android/build/            ← Flutter ephemeral Android build output
//     |         ├── .gradle/                  ← ephemeral Gradle dirs (container-only)
//     |         ├── android/.gradle/          ← ephemeral Gradle dirs (container-only)
//     |         ├── rust/rust_lib/target/     ← Rust ephemeral build output
//     |         └── scripts/                  ← repo scripts
//     |              ├── run_integration_test.sh
//     |              └── generate_PlantUML_PDF.ps1
//     |                           |
//     |  /home/jenkins              ← host-mounted persistent caches
//     |    ├── .gradle              ← mapped from JENKINS_HOST_CACHE/gradle
//     |    ├── .pub-cache           ← mapped from JENKINS_HOST_CACHE/pub
//     |    └── .cargo               ← mapped from JENKINS_HOST_CACHE/cargo
//     +---------------------------+

//  ────────────────────────────────────────────────────────────
//  Host (WSL2 / Linux)
//  ────────────────────────────────────────────────────────────
//  ├── /home/mirko/jenkins_host_home  ← Jenkins workspace host mount (optional)
//  ├── /home/mirko/jenkins_host_cache
//  │     ├── gradle  → /home/jenkins/.gradle in container
//  │     ├── pub     → /home/jenkins/.pub-cache
//  │     └── cargo   → /home/jenkins/.cargo
//  │
//  └── Docker daemon
//        └── /var/run/docker.sock
//  ────────────────────────────────────────────────────────────

//  Volumes & Bind Mounts in docker run:
//  ────────────────────────────────────────────────────────────
//  -v $WORKSPACE:/sudoku_app                   ← Jenkins workspace → build container
//  -v /home/mirko/jenkins_host_cache/gradle:/home/jenkins/.gradle
//  -v /home/mirko/jenkins_host_cache/pub:/home/jenkins/.pub-cache
//  -v /home/mirko/jenkins_host_cache/cargo:/home/jenkins/.cargo
//  ────────────────────────────────────────────────────────────

//  ------------------------------------------------------------
//  Notes:
//  - Workspace = ephemeral, lives under Jenkins container volume:
//      $WORKSPACE/jenkins_container_workspace
//  - Cache = persistent, lives under host mount:
//      $JENKINS_HOST_CACHE → /home/jenkins
//  - Never store persistent caches under $WORKSPACE
//  - Build containers are disposable; source code only lives in workspace
//  ------------------------------------------------------------

//  ------------------------------------------------------------
//  Build artifacts:
//
//    Jenkins archives artifacts from the workspace into:
//
//    /var/jenkins_home/jobs/<job-name>/builds/<build-id>/archive/
//
//  (The workspace itself may be deleted or recreated at any time)
//
//  ------------------------------------------------------------
//  Jenkins container filesystem:
//
//   /var/jenkins_home
//     └── workspace/Flutter_Docker_Pipeline[@N]/jenkins_container_workspace
//           └── scripts/*.sh
//                 │
//                 └── bind-mounted as
//                       ▼
//
//  Flutter build container:
//
//   /sudoku_app/scripts/*.sh
//
//  ------------------------------------------------------------
//  Windows
//   └── WSL2 (Linux VM)
//       └── Docker Engine
//           ├── Jenkins container
//           │   └── /var/jenkins_home/workspace/<job>[@N]/jenkins_container_workspace
//           │         ← SOURCE CODE LIVES HERE (ephemeral)
//           │
//           └── Flutter build container
//               └── /sudoku_app
//                     ← bind-mounted workspace
//
//  ------------------------------------------------------------
//  Persist Jenkins data on the host machine:
//
//   -v /home/mirko/jenkins_host_home:/var/jenkins_home
//
//  Persist build caches on the host machine (IMPORTANT):
//
//   -v /home/mirko/jenkins_host_cache/gradle:/home/jenkins/.gradle
//   -v /home/mirko/jenkins_host_cache/pub:/home/jenkins/.pub-cache
//   -v /home/mirko/jenkins_host_cache/cargo:/home/jenkins/.cargo
//
//   🚨 CACHES MUST NOT BE MOUNTED UNDER $FLUTTER_CONTAINER_WORKSPACE
//
//  ------------------------------------------------------------
//  Docker bind mount syntax:
//     docker run -v <host-path>:<container-path>[:opts]
//
//  Example:
//     docker run \
//       -v $FLUTTER_CONTAINER_WORKSPACE:/sudoku_app \
//       -v /home/mirko/jenkins_host_cache/gradle:/home/jenkins/.gradle \
//       -v /home/mirko/jenkins_host_cache/pub:/home/jenkins/.pub-cache \
//       -v /home/mirko/jenkins_host_cache/cargo:/home/jenkins/.cargo
//
//  ------------------------------------------------------------
//  -w /sudoku_app
//    Sets the working directory inside the container
//    (equivalent to: cd /sudoku_app)
//
//  ------------------------------------------------------------
//  SUMMARY (Golden CI Rule):
//
//    Workspace  = dynamic, disposable sandbox
//    Home dir   = stable, persistent caches
//
//    NEVER store caches under $FLUTTER_CONTAINER_WORKSPACE
//
//  ------------------------------------------------------------
//  ┌──────────────────────────────┐
//  │ Jenkins IMAGE                │  ← static
//  │  - Jenkins                   │
//  │  - Plugins                   │
//  └──────────────┬───────────────┘
//                 │ container start
//                 ▼
//  ┌──────────────────────────────┐
//  │ Jenkins CONTAINER (runtime)  │  ← mutable
//  │                              │
//  │ /var/jenkins_home  (volume)  │
//  │   └── workspace/             │
//  │       └── job@N/jenkins_container_workspace
//  │           └── source code    │  ← checked out here
//  └──────────────┬───────────────┘
//                 │ docker run
//                 ▼
//  ┌──────────────────────────────┐
//  │ Build container              │
//  │  flutter_rust_env            │
//  │                              │
//  │ /sudoku_app  ← bind mount    │
//  │   (same files)               │
//  └──────────────────────────────┘
//
//  ------------------------------------------------------------
//  Options / Purpose
//  ------------------------------------------------------------
//  -d	                                                Run in background
//  --name jenkins_container_sudoku	                    Name the container
//  -p 8080:8080	                                    Jenkins web UI
//  -p 50000:50000	                                    Jenkins agents
//  -v …:/var/jenkins_home	                            Persist Jenkins data
//  -v …:/FLUTTER_CONTAINER_WORKSPACE	                        Persist Jenkins build data
//  -v /var/run/docker.sock:/var/run/docker.sock	    Let Jenkins control Docker
//   jenkins_container_sudoku:lts	                    Jenkins image
//
//  ------------------------------------------------------------
//  DIFFERENT EXECUTION CONTEXTS
//
//  1) Host (WSL2 / Linux)
//     - Owns Docker daemon
//     - Owns persistent volumes
//
//  2) Jenkins container (runtime)
//     - Runs Jenkins
//     - Performs Git checkout into dynamic workspaces
//     - Owns pipeline orchestration
//
//  3) Flutter build container
//     - Stateless
//     - Receives source code via bind mount from Jenkins workspace
//     - Uses host-mounted caches


//  ------------------------------------------------------------
//  Host → Jenkins → Build Container Mapping
//
//  Host (WSL2 / Linux)
//  ├── jenkins_host_home       ← Jenkins data (persistent)
//  ├── jenkins_host_cache           ← Gradle / Pub / Cargo caches
//  │
//  └── Docker daemon
//      │
//      └── Jenkins container
//          └── /var/jenkins_home/workspace/job@N  ← ephemeral source code
//              │
//              └── docker run → flutter_rust_env
//                  ├── /sudoku_app               ← bind-mounted workspace
//                  ├── /home/jenkins/.gradle     ← persistent host cache
//                  ├── /home/jenkins/.pub-cache  ← persistent host cache
//                  └── /home/jenkins/.cargo      ← persistent host cache
//
//  ------------------------------------------------------------
// cd 
// Container (Flutter)
// ┌─────────────────────────────┐
// │ ${FLUTTER_CONTAINER_WORKSPACE}       <- mounted from host /${JOB_NAME}
// │  ├── git_checkout/           <- cloned repo
// │  ├── build/                 <- ephemeral Flutter build output
// │  ├── android/build/         <- ephemeral Android build output
// │  ├── .gradle/               <- ephemeral Gradle output (job local)
// │  └── artifacts/             <- mounted to host artifacts/
// │
// │ ${FLUTTER_CONTAINER_CACHE}           <- mounted from host jenkins_host_cache
// │  ├── .home/                 <- container HOME directory (ephemeral)
// │  ├── .pub-cache             <- Dart/Flutter cache
// │  ├── .gradle                <- Gradle cache
// │  ├── flutter/               <- Flutter engine cache
// │  └── rust/                  <- Rust build cache
// │
// │ ${FLUTTER_ROOT}              <- read-only Flutter SDK
// │ ${RUSTUP_HOME}, ${CARGO_HOME} <- read-only Rust toolchain
// │ ${ANDROID_SDK_ROOT}           <- read-only Android SDK/NDK
// └─────────────────────────────┘
//
//  Key Rules
//
//  1) Workspace (FLUTTER_CONTAINER_WORKSPACE) = ephemeral → safe to delete after build
//  2) Cache (FLUTTER_CONTAINER_CACHE / host-mounted) = persistent → survives builds
//  3) NEVER store caches under ephemeral workspace
//  4) Source code is bind-mounted into build container → reproducible, isolated builds
//  5) Toolchains are read-only inside container
//  
//  
//  ------------------------------------------------------------
// 🔐 Store Secrets in Jenkins
//     Go to:
//     Manage Jenkins → Credentials → Global
// 
//     Create:
// 
//     1️⃣ Secret File
//     Kind: Secret file
//      ID: KEYSTORE_FILE    Upload your upload-keystore.jks
// 
//     2️⃣ Secret Text (3 entries)
//     Create three Secret Text credentials:
//      ID	Value
//      KEYSTORE_PASSWORD	your keystore password
//      KEY_PASSWORD	    your key password
//      KEY_ALIAS	        upload

//  ------------------------------------------------------------




import groovy.transform.Field

@Field
List<String> containerEnv = []


// Helper for default Jenkins user inside container
// Do not pull image from docker hub. use local image which is manually downloaded from dockerhub once
def insideFlutterContainerJenkinsUser(flutterContainerCache, body) {
    docker.image(env.FLUTTER_IMAGE).inside(
        "--user jenkins " +
        "-v ${env.JENKINS_HOST_CACHE}:${flutterContainerCache} "
    ) {
        withEnv(containerEnv) {
            body()
        }
    }
}


// Helper for root user
// Do not pull image from docker hub. use local image which is manually downloaded from dockerhub once
def insideFlutterContainerRootUser(flutterContainerCache, body) {
    docker.image(env.FLUTTER_IMAGE).inside(
        "--user root " +
        "-v ${env.JENKINS_HOST_CACHE}:${flutterContainerCache} "
    ) {
        withEnv(containerEnv) {
            body()
        }
    }
}

// Helper function : shared cleanup function (Groovy) + parametrize behavior

// What it does : 
// Removes build outputs only
// Removes .dart_tool
// Does NOT touch caches
// Does NOT touch JNI or Rust
// Does NOT need root

// When to run : 
// After Setup Environment
// On every build

def flutterCleanLight() {
    insideFlutterContainerJenkinsUser(
        "${FLUTTER_CONTAINER_CACHE}"
    ) {
        sh """#!/usr/bin/env bash
            set -Eeuo pipefail

            echo "🧹 Flutter LIGHT clean (ephemeral only)"

            # ----------------------------------------
            # Verify Flutter SDK immutability
            # ----------------------------------------
            echo "🔒 Verifying Flutter SDK immutability"
            if [ -w "\$FLUTTER_ROOT" ]; then
                echo "❌ Flutter SDK is writable — ABORT"
                exit 1
            fi

            cd "\$FLUTTER_CONTAINER_WORKSPACE"

            # ----------------------------------------
            # Ephemeral build outputs (SAFE)
            # ----------------------------------------
            echo "🧹 Removing Flutter / Android build outputs"
            rm -rf \
                "\${FLUTTER_BUILD_DIRS_1:?}" \
                "\${FLUTTER_BUILD_DIRS_2:?}" \
                "\${FLUTTER_BUILD_DIRS_3:?}" \
                "\${FLUTTER_BUILD_DIRS_4:?}" \
                ".dart_tool" || true

            echo "✅ Flutter LIGHT clean done"
        """
    }
}

// flutterCleanDeep()

// What it does : 
// Everything LIGHT does
// Gradle caches (partial)
// Pub cache
// JNI libs
// Rust artifacts
// What it deliberately does NOT do
// Delete Gradle wrapper
// Delete entire .gradle
// Touch Flutter SDK
// Change permissions

// When to run : 
// Parameter-gated
// Manual / troubleshooting
// Never by default

def flutterCleanDeep() {
    insideFlutterContainerJenkinsUser(
        "${FLUTTER_CONTAINER_CACHE}"
    ) {
        sh """#!/usr/bin/env bash
            set -Eeuo pipefail

            echo "🧹 Flutter DEEP clean (dependency caches)"

            # ----------------------------------------
            # Verify Flutter SDK immutability
            # ----------------------------------------
            echo "🔒 Verifying Flutter SDK immutability"
            if [ -w "\$FLUTTER_ROOT" ]; then
                echo "❌ Flutter SDK is writable — ABORT"
                exit 1
            fi

            cd "\$FLUTTER_CONTAINER_WORKSPACE"

            # ----------------------------------------
            # Ephemeral outputs (same as LIGHT)
            # ----------------------------------------
            echo "🧹 Removing build outputs"
            rm -rf \
                "\${FLUTTER_BUILD_DIRS_1:?}" \
                "\${FLUTTER_BUILD_DIRS_2:?}" \
                "\${FLUTTER_BUILD_DIRS_3:?}" \
                "\${FLUTTER_BUILD_DIRS_4:?}" \
                ".dart_tool" || true

            # ----------------------------------------
            # Gradle + Pub caches (PARTIAL, SAFE)
            # ----------------------------------------
            echo "🧹 Cleaning Gradle & Pub caches"
            rm -rf \
                "\${GRADLE_USER_HOME:?}/daemon" \
                "\${GRADLE_USER_HOME:?}/caches/modules-2" \
                "\${GRADLE_USER_HOME:?}/caches/transforms-*" \
                "\${PUB_CACHE:?}/hosted" \
                "\${PUB_CACHE:?}/git" || true


            # ----------------------------------------
            # JNI libraries
            # ----------------------------------------
            if [ -d "\$ANDROID_JNI_LIBS_DIR" ]; then
                echo "🧹 Removing JNI libraries"
                rm -rf "\$ANDROID_JNI_LIBS_DIR"/* || true
            fi

            # ----------------------------------------
            # Rust artifacts
            # ----------------------------------------
            if [ -d "\$REPO_CHECKOUT_RUST_SUBDIR" ]; then
                echo "🦀 Cleaning Rust artifacts"
                cd "\$REPO_CHECKOUT_RUST_SUBDIR"
                cargo clean || true
            fi

            # ----------------------------------------
            # Gradle artifacts
            # ----------------------------------------
            if [ -d "\$REPO_CHECKOUT_ANDROID_SUBDIR" ]; then
                echo "🦀 Cleaning Gradle artifacts"
                cd "\$REPO_CHECKOUT_ANDROID_SUBDIR"
                ./gradlew -v || true
            fi

            echo "✅ Flutter DEEP clean done"
        """
    }
}




pipeline {

    agent any

    parameters {
        booleanParam(name: 'GRADLE_DEBUG', defaultValue: false, description: 'GRADLE_DEBUG for debugging Gradle issues')
        booleanParam(name: 'RUN_FAST_STATIC', defaultValue: false, description: '[inWork] Run static code analysis for Flutter, Android, and Rust')
        booleanParam(name: 'RUN_HEAVY_STATIC', defaultValue: false, description: '[inWork] Run heavy static analysis for Android and Rust')
        booleanParam(name: 'DEEP_CLEAN', defaultValue: false, description: 'DEEP CLEAN for release / deployement')
        booleanParam(name: 'RUN_INTEGRATION_TESTS', defaultValue: false, description: '[inWork] Run integration tests')

        booleanParam(name: 'RUN_MATERILIZATION_STAGE', defaultValue: false, description: 'Run materialization stage')
        booleanParam(name: 'RUN_PLANTUML_DOCU_BUILD', defaultValue: false, description: 'Run PlantUML documentation build')
        booleanParam(name: 'RUN_ABB_RELEASE_TEST', defaultValue: true, description: 'Run ABB artefact release test')


        choice(
            name: 'BUILD_MODE',
            choices: ['release', 'debug'],
            description: 'Choose build mode'
        )

    }


    options {
        skipDefaultCheckout true
        buildDiscarder(logRotator(
            numToKeepStr: '3'       // keep only last 3 builds
        ))
    }

    environment {

        // HOWTO : 
        // - Avoid references within the ENV block. Because the ENV block is not executed sequentally.
        // - PATH statement only for paths that point to binaries
        // - EXPORT statements are required inside the stage definition to make ENV parameters visible to child functions
        //   Example : export PUB_CACHE=${PUB_CACHE}

        //  Source code paths → relative to workspace
        //  Cache paths → absolute, mounted volume
        //  Toolchains → absolute (inside image)
        //  Never assume / is the workspace

        // Docker container:
        //  - sees workspace
        //  - uses tools
        //  - is disposable

        //  Source code:
        //  - never lives in container FS
        //  - always lives in Jenkins workspace


        // environment versus containerEnv:
        /* Scope

        "environment" is visible to:
            Groovy pipeline code (env.VAR)
            sh steps outside Docker
            Docker arguments (docker.image(...).inside(...))
        Used by Jenkins to:
            Expand strings
            Configure agents
            Construct Docker commands
        Characteristics:
            Static (cannot reference other env vars reliably)
            Evaluated once
            Exists outside containers
            Exported automatically to steps unless shadowed

        "containerEnv" is visible to:
        Visible only:
            inside the Docker container
            inside sh steps executed in that container
        Invisible to:
            Jenkins DSL logic
            Docker arguments
            anything outside inside(...)
        */


        SHELL = '/bin/bash'

        FLUTTER_DISABLE_ANALYTICS   = 'true'
        FLUTTER_SKIP_ANALYTICS      = 'true'

        // Static paths 

        // Flutter build container
        FLUTTER_IMAGE_PULL  = 'mirkoth/flutter_rust_env:latest'
        FLUTTER_IMAGE       = 'mirkoth/flutter_rust_env:latest'


        // Host mount paths
        JENKINS_HOST_CACHE      = '/home/mirko/jenkins_host_cache'
        JENKINS_HOST_HOME       = '/home/mirko/jenkins_host_home'

        // Jenkins home path
        JENKINS_CONTAINER_HOME  = '/var/jenkins_home'


        // Flutter / Rust toolchains inside container
        FLUTTER_ROOT       = '/opt/flutter'
        RUSTUP_HOME        = '/opt/rust/rustup'
        CARGO_HOME         = '/opt/rust/cargo'
        RUST_CARGO_DIR     = '/opt/rust/cargo/bin'

        ANDROID_SDK_ROOT   = '/opt/android/sdk'
        ANDROID_SDK_MANAGER_DISABLE_SDK_INSTALL = 'true'

        ANDROID_NDK_HOME          = '/opt/android/sdk/ndk/28.2.13676358'
        ANDROID_NDK_TOOLCHAIN_DIR = '/opt/android/sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64/bin'


        // Gradle options
        GRADLE_OPTS        = "-Dorg.gradle.daemon=false -Dorg.gradle.parallel=false -Dorg.gradle.worker.max-gradle-workers=1 -Dorg.gradle.vfs.watch=false -Dkotlin.daemon.enabled=false -Dkotlin.compiler.execution.strategy=in-process -Dgradle.download.retry=3 -Xmx1536m -Xms512m"


        // Git branch 
        GIT_REPO_URL        = 'https://github.com/MirkoThulke/Dart_Flutter_Sudoku.git'
        GIT_BRANCH          = 'iteration3'

        REPO_APK_SUBDIR_REL    = 'build/app/outputs/flutter-apk'
        REPO_ABB_SUBDIR_REL    = 'build/app/outputs/bundle/release'


        // Flutter build targets
        TARGET_PLATFORMS    = 'android-arm,android-arm64'

        // PATH definition (binaries only)
        PATH = "/opt/rust/cargo/bin:/opt/flutter/bin:/opt/android/sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64/bin:/opt/android/sdk/cmdline-tools/latest/bin:/opt/android/sdk/platform-tools:$PATH"
    }

    stages {

        // Phase 1 – Container & Infra validation (fail-fast)

        stage('Workspace Sanity Clean') {
            steps {
                cleanWs()
            }
        }


        stage('Define project paths') {
            steps {
                // Dynamic paths inside container (workspace-dependent)
                script {

                    // now WORKSPACE exists

                    env.FLUTTER_CONTAINER_WORKSPACE     = "${WORKSPACE}"
                    env.FLUTTER_CONTAINER_CACHE         = "/jenkins_container_cache"



                    // Prepare ENV exports for child processes
                    /*
                        # workspace owned home directory
                        # Ephemeral workspace

                        # Persistent caches
                        # Flutter ephemeral build dirs
                        # Rust / Android FFI
                        # Toolchains
                        # Scripts (repo relative)
                        # "PATH=${env.PATH}" !!
                    */

                    containerEnv = [

                    // .home should be located inside the container workspace, because some tools (e.g. Gradle) write to it during execution. We cannot point it to a host-mounted directory, because of permission issues. Instead, we create a .home directory inside the container workspace and point HOME to it. This way, tools can write to HOME without permission issues, and we still have separation between ephemeral workspace and persistent caches.
                    "HOME=${env.FLUTTER_CONTAINER_CACHE}/.home",

                    "FLUTTER_DISABLE_ANALYTICS=${env.FLUTTER_DISABLE_ANALYTICS}",
                    "FLUTTER_SKIP_ANALYTICS=${env.FLUTTER_SKIP_ANALYTICS}",


                    "FLUTTER_CONTAINER_WORKSPACE=${env.FLUTTER_CONTAINER_WORKSPACE}",
                    "FLUTTER_CONTAINER_CACHE=${env.FLUTTER_CONTAINER_CACHE}",


                    "FLUTTER_BUILD_DIRS_1=${env.FLUTTER_CONTAINER_WORKSPACE}/build",
                    "FLUTTER_BUILD_DIRS_2=${env.FLUTTER_CONTAINER_WORKSPACE}/android/build",
                    "FLUTTER_BUILD_DIRS_3=${env.FLUTTER_CONTAINER_WORKSPACE}/.gradle",
                    "FLUTTER_BUILD_DIRS_4=${env.FLUTTER_CONTAINER_WORKSPACE}/android/.gradle",

                    "XDG_CONFIG_HOME=${env.FLUTTER_CONTAINER_WORKSPACE}/.home/.config",
                    "XDG_CACHE_HOME=${env.FLUTTER_CONTAINER_CACHE}/.cache",

                    "REPO_CHECKOUT_DIR=${env.FLUTTER_CONTAINER_WORKSPACE}/git_checkout",
                    "REPO_CHECKOUT_RUST_SUBDIR=${env.FLUTTER_CONTAINER_WORKSPACE}/git_checkout/rust/rust_lib",
                    "REPO_CHECKOUT_ANDROID_SUBDIR=${env.FLUTTER_CONTAINER_WORKSPACE}/git_checkout/android",
                    "INTEGRATION_TEST_SCRIPT=${env.FLUTTER_CONTAINER_WORKSPACE}/git_checkout/scripts/run_integration_test.sh",
                    "PLANTUML_SCRIPT=${env.FLUTTER_CONTAINER_WORKSPACE}/git_checkout/scripts/generate_plantuml_pdf.sh",
                    "SCRIPTS_DIR_CONTAINER=${env.FLUTTER_CONTAINER_WORKSPACE}/git_checkout/scripts",

                    "REPO_APK_SUBDIR_REL=${env.REPO_APK_SUBDIR_REL}",
                    "REPO_ABB_SUBDIR_REL=${env.REPO_ABB_SUBDIR_REL}",

                    "FLUTTER_CONTAINER_ARTIFACTS=${env.FLUTTER_CONTAINER_WORKSPACE}/artifacts",


                    "ANDROID_JNI_LIBS_DIR=${env.FLUTTER_CONTAINER_WORKSPACE}/android/app/src/main/jniLibs",

                    "FLUTTER_ROOT=${env.FLUTTER_ROOT}",
                    "RUSTUP_HOME=${env.RUSTUP_HOME}",
                    "CARGO_HOME=${env.CARGO_HOME}",
                    "RUST_CARGO_DIR=${env.RUST_CARGO_DIR}",

                    "ANDROID_SDK_ROOT=${env.ANDROID_SDK_ROOT}",
                    "ANDROID_SDK_MANAGER_DISABLE_SDK_INSTALL=${env.ANDROID_SDK_MANAGER_DISABLE_SDK_INSTALL}",

                    "ANDROID_NDK_HOME=${env.ANDROID_NDK_HOME}",
                    "ANDROID_NDK_TOOLCHAIN_DIR=${env.ANDROID_NDK_TOOLCHAIN_DIR}",

                    // Force Gradle writes outside the Flutter SDK.
                    // Flutter invokes Gradle via Java, so we must override both
                    // GRADLE_USER_HOME and the Java user.home property.
                    // This is a problem because the Flutter SDK is read-only in our container, 
                    // so we point it to a writable location inside the container cache.

                    "PUB_CACHE=${env.FLUTTER_CONTAINER_CACHE}/.pub-cache",
                    "GRADLE_USER_HOME=${env.FLUTTER_CONTAINER_CACHE}/.gradle",
                    "FLUTTER_GRADLE_USER_HOME=${env.FLUTTER_CONTAINER_CACHE}/flutter-gradle",
                    "FLUTTER_CACHE_DIR=${env.FLUTTER_CONTAINER_CACHE}/flutter",


                    "GRADLE_OPTS=${env.GRADLE_OPTS}",


                    "GIT_REPO_URL=${env.GIT_REPO_URL}",
                    "GIT_BRANCH=${env.GIT_BRANCH}",

                    "TARGET_PLATFORMS=${env.TARGET_PLATFORMS}",

                    "PATH=${env.PATH}"
                    ]

                }
            }
        }


        stage('Setup Environment') {
            steps {
                script {
                    insideFlutterContainerJenkinsUser(
                        "${FLUTTER_CONTAINER_CACHE}"
                    ) {
                        sh """#!/usr/bin/env bash
                            set -Eeuo pipefail

                        # Create the required  directories inside the container

                        cd \${WORKSPACE}

                            mkdir -p \
                                "\$FLUTTER_CONTAINER_WORKSPACE" \
                                "\$FLUTTER_CONTAINER_ARTIFACTS" \
                                "\$FLUTTER_CONTAINER_CACHE/.gradle/caches" \
                                "\$FLUTTER_CONTAINER_CACHE/.gradle/wrapper" \
                                "\$FLUTTER_CACHE_DIR" \
                                "\$HOME" \
                                "\$HOME/.android" \
                                "\$HOME/.gradle" \
                                "\$XDG_CONFIG_HOME/flutter" \
                                "\$XDG_CACHE_HOME" \
                                "\$FLUTTER_GRADLE_USER_HOME" \
                                "\$GRADLE_USER_HOME" \
                                "\$PUB_CACHE"

                            chmod u+rwX "$PUB_CACHE" "$GRADLE_USER_HOME" || true


                            # Optional: verify the directories
                            echo "inside container:"
                            ls -la "\${FLUTTER_CONTAINER_WORKSPACE}" || true
                            ls -la "\${FLUTTER_CONTAINER_CACHE}" || true
                            ls -la "\$HOME/.config" || true

                            # Guard against misconfiguration: ensure HOME is not accidentally set to a host path
                            test "\$HOME" != "/home/jenkins"

                            echo "HOME=\$HOME"
                            stat "\$HOME"
                            test -w "\$HOME"
                            test ! -w "\$FLUTTER_ROOT"

                            test -w "\$GRADLE_USER_HOME"
                            test -w "\$FLUTTER_CACHE_DIR"
                            test -w "\$FLUTTER_GRADLE_USER_HOME"
                            test -w "\$FLUTTER_CONTAINER_ARTIFACTS"


                        """
                    }
                }
            }
        }


        stage('CI Self-Test') {
            steps {
                echo "🧪 Running CI Self-Test (fail-fast)"
                script {                
                    insideFlutterContainerJenkinsUser(
                    "${FLUTTER_CONTAINER_CACHE}"
                    ) {
                    sh """#!/usr/bin/env bash

                        set -Eeuo pipefail

                        cd \${WORKSPACE}

                        section() {
                            echo
                            echo "=============================="
                            echo "\$1"
                            echo "=============================="
                        }

                        fail() {
                            echo "❌ ERROR: \$1"
                            exit 1
                        }

                        check() {
                            "\$@" || fail "Command failed: \$*"
                        }

                        require_env() {
                            var="\$1"
                            val="\${!var:-}"
                            [ -n "\$val" ] || fail "Missing ENV variable: \$var"
                        }

                        section "CI SELF TEST"

                        require_env HOME
                        require_env FLUTTER_ROOT
                        require_env FLUTTER_CACHE_DIR
                        require_env FLUTTER_CONTAINER_WORKSPACE
                        require_env FLUTTER_CONTAINER_CACHE
                        require_env GRADLE_USER_HOME
                        require_env FLUTTER_GRADLE_USER_HOME
                        require_env RUST_CARGO_DIR
                        require_env RUSTUP_HOME
                        require_env CARGO_HOME
                        require_env ANDROID_SDK_ROOT
                        require_env ANDROID_NDK_HOME
                        require_env PUB_CACHE
                        require_env WORKSPACE


                        section "Workspace & cache mounts"
                        check test -d "\${FLUTTER_CONTAINER_WORKSPACE}"
                        check test -w "\${FLUTTER_CONTAINER_WORKSPACE}"
                        check test -d "\${FLUTTER_CONTAINER_CACHE}"
                        check test -w "\${FLUTTER_CONTAINER_CACHE}"
                        echo "✅ Workspace & cache are mounted and writable"

                        section "Toolchain availability"
                        check command -v flutter
                        check command -v dart
                        check command -v cargo


                        section "Android SDK / NDK sanity"
                        check test -d "\${ANDROID_SDK_ROOT}"
                        check test -d "\${ANDROID_NDK_HOME}"
                        check test -d "\${ANDROID_NDK_TOOLCHAIN_DIR}"
                        echo "✅ Android SDK & NDK OK"


                        # Gradle user home should be writable and point to the cache
                        echo "GRADLE_USER_HOME=\$GRADLE_USER_HOME"
                        env | grep -E 'GRADLE|JAVA'

                        # Flutter engine artifacts should be writable in the cache, but not in the SDK
                        ls -l "\${FLUTTER_ROOT}/bin/cache/artifacts/engine"

                        echo "Cargo version:"
                        cargo --version

                        echo "Flutter version:"
                        flutter --version

                        echo "Android SDK check:"
                        ls -d "\${ANDROID_SDK_ROOT}/platforms/*" || true

                        echo "Verify Flutter SDK is read-only:"
                        test ! -w "\${FLUTTER_ROOT}" && echo "SDK locked (OK)" || (echo "SDK writable (ERROR)" && exit 1)

                        echo "Ensuring no Flutter SDK writes possible:"
                        if touch "\${FLUTTER_ROOT}/should_fail" 2>/dev/null; then
                            echo "ERROR: Flutter SDK is writable!"
                            exit 1
                        else
                            echo "Write blocked (OK)"
                        fi


                        echo "=============================="
                        echo "✅ CI SELF TEST PASSED"
                        echo "=============================="

                        sync || true
                        sleep 1
                    """
                    }
                }
            }
        }


        stage('Check Mount') {
            steps {
                script {                
                    insideFlutterContainerJenkinsUser(
                    "${FLUTTER_CONTAINER_CACHE}"
                    ) {
                        sh """#!/usr/bin/env bash

                            set -Eeuo pipefail

                            cd \${WORKSPACE}

                            echo "Container Cache: \${FLUTTER_CONTAINER_CACHE}" && ls -la "\${FLUTTER_CONTAINER_CACHE}" || echo "Cache empty"
                            echo "Container Workspace: \${FLUTTER_CONTAINER_WORKSPACE}" && ls -la "\${FLUTTER_CONTAINER_WORKSPACE}" || echo "Cache empty"
                        """
                    }
                }
            }
        }


        stage('Verify Container Layout') {

            steps {
                script {                
                    insideFlutterContainerJenkinsUser(
                    "${FLUTTER_CONTAINER_CACHE}"
                    ) {
                    sh """#!/usr/bin/env bash

                        set -Eeuo pipefail

                        cd \${WORKSPACE}

                        echo "== Flutter =="
                        which flutter
                        flutter --version
    
                        echo "== Workspace =="
                        pwd
                        ls -la
    
                        echo "== Cache =="
                        ls -la \${FLUTTER_CONTAINER_CACHE} || true
    
                        echo "== Env =="
                        env | sort
                    """
                    }
                }
            }
        }


        // Phase 2 – Source control

        stage('Checkout in Container') {
            steps {
                script {
                    insideFlutterContainerJenkinsUser(
                        "${FLUTTER_CONTAINER_CACHE}"
                    ) {
                        sh """#!/usr/bin/env bash
                            set -Eeuo pipefail

                            cd \${FLUTTER_CONTAINER_WORKSPACE}

                            # Clone repo inside container
                            if [ ! -d "${REPO_CHECKOUT_DIR}/.git" ]; then
                                git clone --branch "${GIT_BRANCH}" "${GIT_REPO_URL}" "${REPO_CHECKOUT_DIR}"
                            else
                                echo "Repo already cloned"
                                cd "${REPO_CHECKOUT_DIR}"
                                git fetch --all
                                git reset --hard ${GIT_BRANCH}
                            fi

                            # Ensure Gradle wrapper is executable
                            cd "\${REPO_CHECKOUT_ANDROID_SUBDIR}"
                            chmod +x gradlew
                            ./gradlew -v || true

                            cd \${FLUTTER_CONTAINER_WORKSPACE}

                            # Verify files
                            ls -la "${REPO_CHECKOUT_DIR}"
                            ls -la "${REPO_CHECKOUT_RUST_SUBDIR}/src"
                        """
                    }
                }
            }
        }


        stage('Validate Repo Structure') {
            steps {
                script {
                    insideFlutterContainerJenkinsUser(
                        "${FLUTTER_CONTAINER_CACHE}"
                    ) {
                        sh """#!/usr/bin/env bash
                            set -Eeuo pipefail
                            cd "\${REPO_CHECKOUT_DIR}"

                            # scripts directory (repo-relative)
                            if [ ! -d scripts ]; then
                                echo "❌ scripts/ directory not found in repository"
                                exit 1
                            fi

                            #  Flutter mandatory file
                            if [ ! -f pubspec.yaml ]; then
                                echo "❌ pubspec.yaml missing"
                                exit 1
                            fi

                            #  Optional but recommended
                            if [ ! -d android ]; then
                                echo "❌ android/ directory missing"
                                exit 1
                            fi

                            echo "✅ Repository structure valid"
                        """
                    }
                }
            }
        }


        stage('Verify Rust Source') {
            steps {
                script {
                    insideFlutterContainerJenkinsUser(
                    "${FLUTTER_CONTAINER_CACHE}"
                    ) { 

                        sh """#!/usr/bin/env bash
                        set -Eeuo pipefail
                        
                        # Ensure we are in the workspace
                        cd "\${FLUTTER_CONTAINER_WORKSPACE}"


                        echo "=== Container workspace ==="
                        ls -la "\${FLUTTER_CONTAINER_WORKSPACE}"

                        echo "Container workspace: \${FLUTTER_CONTAINER_WORKSPACE}"

                        if [ -d "\${REPO_CHECKOUT_RUST_SUBDIR}/src" ]; then
                            echo "=== Rust src directory ==="
                            ls -la "\${REPO_CHECKOUT_RUST_SUBDIR}/src"
                        else
                            echo "ERROR: rust_lib/src folder does not exist!"
                            exit 1
                        fi
                        """
                    }
                }
            }
        }


        stage('Static Analysis (FAST)') {
            when {
                expression { params.RUN_FAST_STATIC}
            }
            steps {
                script {
                    insideFlutterContainerJenkinsUser(
                        "${FLUTTER_CONTAINER_CACHE}"
                    ) {
                        parallel(
                            "Flutter": {
                                sh """#!/usr/bin/env bash
                                set -Eeuo pipefail
                                    cd "\${REPO_CHECKOUT_DIR}"

                                    echo "🧪 Flutter FAST analysis"
                                    flutter pub get
                                    dart format --output=none --set-exit-if-changed .
                                    flutter analyze --fatal-infos --fatal-warnings
                                """
                            },
                            "Rust": {
                                sh """#!/usr/bin/env bash
                                    set -Eeuo pipefail
                                    cd "\${REPO_CHECKOUT_RUST_SUBDIR}"

                                    echo "🦀 Rust FAST analysis"
                                    cargo fmt -- --check
                                    cargo check
                                """
                            }
                        )
                    }
                }
            }
        }

        stage('Static Analysis (HEAVY)') {
            when {
                expression { params.RUN_HEAVY_STATIC }
            }
            steps {
                script {
                    insideFlutterContainerJenkinsUser(
                        "${FLUTTER_CONTAINER_CACHE}"
                    ) {
                        parallel(
                            "Android": {
                                sh """#!/usr/bin/env bash
                                    set -Eeuo pipefail
                                    cd "\${REPO_CHECKOUT_ANDROID_SUBDIR}"

                                    echo "🤖 Android HEAVY analysis"
                                    ./gradlew lint
                                """
                            },
                            "Rust": {
                                sh """#!/usr/bin/env bash
                                    set -Eeuo pipefail
                                    cd "\${REPO_CHECKOUT_RUST_SUBDIR}"

                                    echo "🦀 Rust HEAVY analysis"
                                    cargo clippy -- -D warnings
                                    cargo audit || true
                                """
                            }
                        )
                    }
                }
            }
        }


        // Phase 3 – Cleaning (safe + deterministic)

        stage('Clean Environment Flutter') {
            steps {
                script {
                    flutterCleanLight()
                }
            }
        }


        stage('Deep Clean (optional)') {
            when { expression { params.DEEP_CLEAN == true } }
            steps {
                script {
                    flutterCleanDeep()
                }
            
            }
        }


        // Phase 4 – Build graph

        stage('Build Rust (Android FFI)') {
            steps {
                // /var/jenkins_home/workspace/Flutter_Docker_Pipeline/rust/rust_lib: No such file or directory
                script {
                    insideFlutterContainerJenkinsUser(
                    "${FLUTTER_CONTAINER_CACHE}"
                    ) {
                        echo "🦀 Building Rust backend for Android (FFI)"
                        sh """#!/usr/bin/env bash
                        set -Eeuo pipefail

                        # cd into Rust project
                        cd "\${REPO_CHECKOUT_RUST_SUBDIR}"

                        command -v cargo-ndk >/dev/null || {
                        echo "❌ cargo-ndk missing"
                        exit 1
                        }
        
                        echo "🧹 Cleaning previous Rust build"
                        cargo clean
        
                        echo "⚙️ Building Rust libraries via cargo-ndk"
                        cargo ndk \
                          -t armeabi-v7a \
                          -t arm64-v8a \
                          -t x86_64 \
                          -o "\${ANDROID_JNI_LIBS_DIR}" \
                              build --release
        
                            echo "📦 Produced JNI libraries:"
                        find "\${ANDROID_JNI_LIBS_DIR}" -name "*.so"
                        """
                    }
                }
            }
        }


        stage('Flutter → Android Materialization') {
            when { expression { params.RUN_MATERILIZATION_STAGE}}
            steps {
               script {
                    insideFlutterContainerJenkinsUser(
                    "${FLUTTER_CONTAINER_CACHE}"
                    ) {
                        def gradleDebugOn = params.GRADLE_DEBUG as boolean
                        

                        sh """#!/usr/bin/env bash
                        set -Eeuo pipefail

                        require_env() {
                            var="\$1"
                            val="\${!var:-}"
                            [ -n "\$val" ] || fail "Missing ENV variable: \$var"
                        }

                        echo "📦 Flutter pub get and build APK"

                        require_env FLUTTER_ROOT
                        require_env REPO_CHECKOUT_DIR

                        cd "\${REPO_CHECKOUT_DIR}"   # Project root containing pubspec.yaml


                        # Flutter engine artifacts should be writable in the cache, but not in the SDK
                        ls -l "\${FLUTTER_ROOT}/bin/cache/artifacts/engine"

                        # Ensure Gradle wrapper is executable
                        cd "\${REPO_CHECKOUT_ANDROID_SUBDIR}"
                        chmod +x gradlew
                        ./gradlew -v || true

                        # Flutter environment

                        cd "\${REPO_CHECKOUT_DIR}"   # Project root containing pubspec.yaml

                        # explicitly force Gradle’s user home at invocation time, not just via env.
                        export HOME="$HOME"
                        export GRADLE_USER_HOME="$GRADLE_USER_HOME"
                        export FLUTTER_GRADLE_USER_HOME="$FLUTTER_GRADLE_USER_HOME"
                        export ANDROID_HOME="$ANDROID_SDK_ROOT"
                        export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
                        export PUB_CACHE="$PUB_CACHE"
                        export PATH="$PATH"

                        # Gradle configuration for CI environment (disable daemons, parallelism, and VFS watching for stability in CI)
                        export ORG_GRADLE_PROJECT_org_gradle_daemon=false
                        export ORG_GRADLE_PROJECT_org_gradle_parallel=false
                        export ORG_GRADLE_PROJECT_org_gradle_workers_max=1
                        export ORG_GRADLE_PROJECT_org_gradle_vfs_watch=false

                        echo "HOME=$HOME"
                        echo "GRADLE_USER_HOME=$GRADLE_USER_HOME"
                        echo "PUB_CACHE=$PUB_CACHE"

                        test -w "$HOME"
                        test -w "$GRADLE_USER_HOME"
                        test ! -w "$FLUTTER_ROOT"

                        echo "FLUTTER_ROOT=$FLUTTER_ROOT"
                        cd "\${REPO_CHECKOUT_DIR}"   # Project root containing pubspec.yaml
                        which flutter
                        flutter --version

                        ls -la /opt/flutter/packages/flutter_tools/gradle/src/main || true

                        # Fetch Dart dependencies
                        flutter pub get

                        # Build debug APK (wires Gradle)

                        echo "=== ANDROID / GRADLE SANITY ==="

                        # Java tools must exist
                        java -version
                        javac -version || true

                        echo "HOME=$HOME"
                        echo "GRADLE_USER_HOME=$GRADLE_USER_HOME"
                        echo "ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT"

                        # Safe to ignore errors
                        ls -ld "$GRADLE_USER_HOME"  || true
                        ls -ld "$ANDROID_SDK_ROOT" || true
                        ls -ld "$FLUTTER_ROOT"      || true
                        ls -la "$GRADLE_USER_HOME"  || true

                        # Gradle CLI / Wrapper check
                        cd "\${REPO_CHECKOUT_ANDROID_SUBDIR}"   # Project root containing pubspec.yaml
                        ./gradlew -v || true


                        echo "=== GRADLE WRAPPER ==="
                        cd "\${REPO_CHECKOUT_ANDROID_SUBDIR}"
                        grep distributionUrl gradle/wrapper/gradle-wrapper.properties || true
                        grep "com.android.tools.build:gradle" -R build.gradle* || true


                        cd "\${REPO_CHECKOUT_DIR}"   # Project root containing pubspec.yaml

                        if [ "${gradleDebugOn}" = "true" ]; then
                            export ORG_GRADLE_PROJECT_org_gradle_stacktrace=true
                            export ORG_GRADLE_PROJECT_org_gradle_debug=true
                        fi

                        # The Flutter Gradle plugin should be resolved and functional, otherwise the build will fail with a clear error.
                        ls "$FLUTTER_ROOT/packages/flutter_tools/gradle/flutter.gradle"
                        
                        flutter build apk \
                            --debug \
                            --ci \
                            --no-shrink \
                            --target-platform \$TARGET_PLATFORMS


                        # Verify AFTER build
                        echo "✅ Engine artifacts:"
                        find "\${FLUTTER_ROOT}/bin/cache/artifacts/engine" -name "flutter.jar"

                        echo "✅ Flutter build complete"
                        """

                    }

                }
            }
        }


        // Phase 5 – Diagnostics

        stage('Flutter Deep Diagnostics') {
          steps {
            script {
                insideFlutterContainerJenkinsUser(
                "${FLUTTER_CONTAINER_CACHE}"
                ) {

                sh """#!/usr/bin/env bash
                set -Eeuo pipefail

                    # read-only diagnostics !

                    cd "\${REPO_CHECKOUT_DIR}"   # Project root containing pubspec.yaml

                    echo "Flutter environment diagnostics:"
                    flutter --version || true

                    echo "Dart version:"
                    dart --version || true

                    echo 'Gradle wrapper version:'
                    ./android/gradlew -v

                    echo 'Java version:'
                    java -version || true

                    echo "Android SDK location:"
                    echo \$ANDROID_SDK_ROOT
                    ls -lah \$ANDROID_SDK_ROOT || true

                    echo "Engine cache:"
                    ls -lah \${FLUTTER_ROOT}/bin/cache/artifacts/engine || true

                    echo "JNI intermediates:"
                    find build -path "*jniLibs*" -maxdepth 6 || true

                    echo "Gradle cache:"
                    ls -lah \$GRADLE_USER_HOME/caches | head -n 20
        
                """
              }
            }
          }
        }


        stage('Inject Android Signing') {
            when { expression { params.BUILD_MODE == 'release' } }
            steps {
                withCredentials([
                    file(credentialsId: 'android-upload-keystore', variable: 'KEYSTORE_FILE'),
                    string(credentialsId: 'android-store-password', variable: 'STORE_PASSWORD'),
                    string(credentialsId: 'android-key-password', variable: 'KEY_PASSWORD'),
                    string(credentialsId: 'android-key-alias', variable: 'KEY_ALIAS')
                ]) {
                    insideFlutterContainerJenkinsUser("${FLUTTER_CONTAINER_CACHE}") {
                        sh """#!/usr/bin/env bash
                            set -Eeuo pipefail

                            cd "${REPO_CHECKOUT_DIR}/android"

                            echo "🔐 Injecting Android signing config..."

                            # Create keystore directory
                            mkdir -p keystore
                            cp "$KEYSTORE_FILE" keystore/upload-keystore.jks

                            # Create key.properties
                            cat > key.properties <<EOF
                            storePassword=$STORE_PASSWORD
                            keyPassword=$KEY_PASSWORD
                            keyAlias=$KEY_ALIAS
                            storeFile=keystore/upload-keystore.jks
                            EOF

                            echo "✅ key.properties generated securely"
                        """
                    }
                }
            }
        }


        // Phase 6 – Final artifacts

        stage('Build APK/AAB') {
            steps {
                script {
                    insideFlutterContainerJenkinsUser(
                    "${FLUTTER_CONTAINER_CACHE}"
                    ) {
                        
                        def gradleDebugOn = params.GRADLE_DEBUG as boolean

                        if (params.BUILD_MODE == 'release') {
                            sh """#!/usr/bin/env bash
                                set -Eeuo pipefail

                                echo "🚀 Building release APK/AAB"

                                cd \${REPO_CHECKOUT_DIR}
                                echo "Using APK path: \$REPO_APK_SUBDIR_REL"
                                echo "Using AAB path: \$REPO_ABB_SUBDIR_REL"

                                if [ "${gradleDebugOn}" = "true" ]; then
                                    export ORG_GRADLE_PROJECT_org_gradle_stacktrace=true
                                    export ORG_GRADLE_PROJECT_org_gradle_debug=true

                                    flutter build apk \
                                    --release \
                                    --ci \
                                    --no-shrink \
                                    --verbose \
                                    --target-platform \$TARGET_PLATFORMS

                                    flutter build appbundle \
                                    --release \
                                    --ci \
                                    --no-shrink \
                                    --verbose \
                                    --target-platform \$TARGET_PLATFORMS

                                else

                                    flutter build apk \
                                        --release \
                                        --ci \
                                        --no-shrink \
                                        --target-platform \$TARGET_PLATFORMS

                                    flutter build appbundle \
                                        --release \
                                        --ci \
                                        --no-shrink \
                                        --target-platform \$TARGET_PLATFORMS
                                fi

                                echo "Ensuring Host artifacts directory is writable from INSIDE of the container:"
                                if touch "\$FLUTTER_CONTAINER_ARTIFACTS/should_pass" 2>/dev/null; then
                                    echo "PASS: Host artifacts directory is writable!"
                                else
                                    echo "Write blocked (FAILED)"
                                    exit 1
                                fi

                                # Copy APKs

                                cd \${REPO_CHECKOUT_DIR}

                                if compgen -G "\$REPO_APK_SUBDIR_REL/*.apk" > /dev/null; then
                                    cp "\$REPO_APK_SUBDIR_REL"/*.apk "\$FLUTTER_CONTAINER_ARTIFACTS"/
                                else
                                    echo "⚠️ No APKs found in \$REPO_APK_SUBDIR_REL"
                                fi

                                # Copy AABs
                                if compgen -G "\$REPO_ABB_SUBDIR_REL/*.aab" > /dev/null; then
                                    cp "\$REPO_ABB_SUBDIR_REL"/*.aab "\$FLUTTER_CONTAINER_ARTIFACTS"/
                                else
                                    echo "⚠️ No AABs found in \$REPO_ABB_SUBDIR_REL"
                                fi

                                 echo "✅ APKs and AABs copied to \$FLUTTER_CONTAINER_ARTIFACTS/"
                                 ls -la "\$FLUTTER_CONTAINER_ARTIFACTS"

                            """
                        } else {
                            sh """#!/usr/bin/env bash
                                set -Eeuo pipefail

                                cd \${REPO_CHECKOUT_DIR}
                                echo "Using APK path: \$REPO_APK_SUBDIR_REL"


                                flutter build apk \
                                    --debug \
                                    --ci \
                                    --no-shrink \
                                    --target-platform \$TARGET_PLATFORMS

                                echo "Ensuring Container artifacts directory is writable from INSIDE of the container:"
                                if touch "\$FLUTTER_CONTAINER_ARTIFACTS/should_pass" 2>/dev/null; then
                                    echo "PASS: Container artifacts directory is writable!"
                                else
                                    echo "Write blocked (FAILED)"
                                    exit 1
                                fi

                                # Copy APKs

                                cd \${REPO_CHECKOUT_DIR}

                                if compgen -G "\$REPO_APK_SUBDIR_REL/*.apk" > /dev/null; then
                                    cp "\$REPO_APK_SUBDIR_REL"/*.apk "\$FLUTTER_CONTAINER_ARTIFACTS"/
                                else
                                    echo "⚠️ No APKs found in \$REPO_APK_SUBDIR_REL"
                                fi

                                echo "✅ APKs and AABs copied to \$FLUTTER_CONTAINER_ARTIFACTS/"
                                ls -la "\$FLUTTER_CONTAINER_ARTIFACTS"

                            """
                        }
                    }
                }
            }
        }


        stage('Archive Artifacts') {
            steps {

                    archiveArtifacts artifacts: "artifacts/**",
                        fingerprint: true,
                        allowEmptyArchive: false

            }
        }


        // Phase 7 – Validation & extras

        stage('Run Integration Tests') {
            when { expression { params.RUN_INTEGRATION_TESTS == true } }
            steps {
                script {                
                    insideFlutterContainerJenkinsUser("${FLUTTER_CONTAINER_CACHE}") {
                        withEnv(["BUILD_MODE=${params.BUILD_MODE}"]) {
                            sh """#!/usr/bin/env bash
                                set -Eeuo pipefail
                                cd "${REPO_CHECKOUT_DIR}"
                                ${INTEGRATION_TEST_SCRIPT}
                            """
                        }
                    }
                }
            }
        }



        stage('Validate Release AAB') {
            when {
                allOf {
                    expression { params.RUN_ABB_RELEASE_TEST == true }
                    expression { params.BUILD_MODE == 'release' }
                }
            }
            steps {
                script {
                    insideFlutterContainerJenkinsUser("${FLUTTER_CONTAINER_CACHE}") {
                        sh """#!/usr/bin/env bash
                        
                        set -Eeuo pipefail
                        set -x

                        cd "\${REPO_CHECKOUT_DIR}"

                        # --------------------------------------------------
                        # Ensure AAB path variable exists
                        # --------------------------------------------------

                        if [ -z "\${REPO_ABB_SUBDIR_REL:-}" ]; then
                          echo "❌ REPO_ABB_SUBDIR_REL not set"
                          exit 1
                        fi

                        AAB="\${REPO_ABB_SUBDIR_REL}/app-release.aab"

                        echo "🔎 Checking AAB existence..."
                        test -f "\$AAB"

                        # --------------------------------------------------
                        # Install bundletool (cached)
                        # --------------------------------------------------

                        BUNDLETOOL_VERSION=1.15.6
                        BUNDLE_DIR="\${FLUTTER_CONTAINER_CACHE}/tools"
                        mkdir -p "\$BUNDLE_DIR"

                        if [ ! -f "\$BUNDLE_DIR/bundletool.jar" ]; then
                          echo "📥 Downloading bundletool \${BUNDLETOOL_VERSION}..."
                          curl -L -o "\$BUNDLE_DIR/bundletool.jar" \
                            "https://github.com/google/bundletool/releases/download/\${BUNDLETOOL_VERSION}/bundletool-all-\${BUNDLETOOL_VERSION}.jar"
                        fi

                        # --------------------------------------------------
                        # Verify signature
                        # --------------------------------------------------

                        echo "🔐 Verifying AAB signature..."

                        if command -v apksigner >/dev/null 2>&1; then
                          apksigner verify --verbose "\$AAB"
                        else
                            jarsigner -verify -verbose -certs -strict "\$AAB" | tee verify.txt
                            grep -q "jar verified" verify.txt || { echo "❌ AAB NOT SIGNED"; exit 1; }
                        fi


                        # --------------------------------------------------
                        # Validate bundle structure
                        # --------------------------------------------------

                        echo "📦 Validating bundle structure..."
                        java -jar "\$BUNDLE_DIR/bundletool.jar" validate --bundle="\$AAB"

                        # --------------------------------------------------
                        # Dump version info (Play Store critical check)
                        # --------------------------------------------------

                        echo "📄 Manifest version info:"
                        java -jar "\$BUNDLE_DIR/bundletool.jar" dump manifest \
                          --bundle="\$AAB" \
                          --xpath=/manifest/@android:versionCode

                        java -jar "\$BUNDLE_DIR/bundletool.jar" dump manifest \
                          --bundle="\$AAB" \
                          --xpath=/manifest/@android:versionName

                        echo "✅ AAB validation successful"
                        """
                    }
                }
            }
        }


        stage('Generate Diagrams & PDF') {
            when { expression { params.RUN_PLANTUML_DOCU_BUILD == true } }
            steps {
                script {
                    insideFlutterContainerJenkinsUser(
                        "${FLUTTER_CONTAINER_CACHE}"
                    ) {
                        sh """#!/usr/bin/env bash

                            set -Eeuo pipefail
        
                            cd "\${REPO_CHECKOUT_DIR}"
        
                            echo "Running PlantUML generator..."
        
                            ./scripts/generate_plantuml.sh
                        """
                    }
                }
            }
        }


    }

    post {
        always {
            echo "🧹 Cleaning workspace"
    
            sh 'rm -f android/key.properties || true'
    
            cleanWs(deleteDirs: true, disableDeferredWipeout: true)
        }
        success { echo "✅ Build succeeded" }
        failure { echo "❌ Build failed" }
    }

}