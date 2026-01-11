//  ------------------------------------------------------------
//  ------------------------------------------------------------
//  RUN THE JENKINS CONTAINER — STEP 1/4
//
//  Prepare HOST directories (persistent)
//
//  sudo mkdir -p /home/mirko/jenkins_host_workspace
//  sudo chown -R 2000:2000 /home/mirko/jenkins_host_workspace
//  sudo chmod -R 770 /home/mirko/jenkins_host_workspace
//
//  sudo mkdir -p /home/mirko/jenkins_host_cache/gradle
//  sudo mkdir -p /home/mirko/jenkins_host_cache/pub
//  sudo mkdir -p /home/mirko/jenkins_host_cache/cargo
//
//  sudo chown -R 2000:2000 /home/mirko/jenkins_host_cache
//  sudo chmod -R 770 /home/mirko/jenkins_host_cache

// Start the Jenkins Docker container via : compose build via your compose.yaml file
//     docker compose up -d --build
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
//  CI Workflow: GitHub → Jenkins (container) → flutter_rust_env (build container)
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
//     -v $CONTAINER_WORKSPACE:/sudoku_app
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
//     |    ├── .gradle              ← mapped from HOST_CACHE/gradle
//     |    ├── .pub-cache           ← mapped from HOST_CACHE/pub
//     |    └── .cargo               ← mapped from HOST_CACHE/cargo
//     +---------------------------+

//  ────────────────────────────────────────────────────────────
//  Host (WSL2 / Linux)
//  ────────────────────────────────────────────────────────────
//  ├── /home/mirko/jenkins_host_workspace  ← Jenkins workspace host mount (optional)
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
//      $HOST_CACHE → /home/jenkins
//  - Never store persistent caches under $WORKSPACE
//  - Build containers are disposable; source code only lives in workspace
//  ------------------------------------------------------------

//  ------------------------------------------------------------
//  Build artefacts:
//
//    Jenkins archives artefacts from the workspace into:
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
//   -v /home/mirko/jenkins_host_workspace:/var/jenkins_home
//
//  Persist build caches on the host machine (IMPORTANT):
//
//   -v /home/mirko/jenkins_host_cache/gradle:/home/jenkins/.gradle
//   -v /home/mirko/jenkins_host_cache/pub:/home/jenkins/.pub-cache
//   -v /home/mirko/jenkins_host_cache/cargo:/home/jenkins/.cargo
//
//   🚨 CACHES MUST NOT BE MOUNTED UNDER $CONTAINER_WORKSPACE
//
//  ------------------------------------------------------------
//  Docker bind mount syntax:
//     docker run -v <host-path>:<container-path>[:opts]
//
//  Example:
//     docker run \
//       -v $CONTAINER_WORKSPACE:/sudoku_app \
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
//    NEVER store caches under $CONTAINER_WORKSPACE
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
//  -v …:/CONTAINER_WORKSPACE	                            Persist Jenkins build data
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
//  ├── jenkins_host_workspace       ← Jenkins data (persistent)
//  ├── jenkins_host_cache           ← Gradle / Pub / Cargo caches
//  │
//  └── Docker daemon
//      │
//      └── Jenkins container
//          └── /var/jenkins_home/workspace/job@N  ← ephemeral source code
//              │
//              └── docker run → flutter_rust_env
//                  ├── /sudoku_app       ← bind-mounted workspace
//                  ├── /home/jenkins/.gradle     ← persistent host cache
//                  ├── /home/jenkins/.pub-cache  ← persistent host cache
//                  └── /home/jenkins/.cargo      ← persistent host cache
//
//  ------------------------------------------------------------
//  Key Rules
//
//  1) Workspace (CONTAINER_WORKSPACE) = ephemeral → safe to delete after build
//  2) Cache (CONTAINER_CACHE / host-mounted) = persistent → survives builds
//  3) NEVER store caches under ephemeral workspace
//  4) Source code is bind-mounted into build container → reproducible, isolated builds
//  5) Toolchains are read-only inside container


// Helper for default Jenkins user inside container
def insideFlutterContainerJenkinsUser(containerWorkspace, containerCache, body) {
    docker.image(env.FLUTTER_IMAGE).inside(
        "-v ${env.HOST_CACHE}:${containerCache} " +
        "-v ${env.HOST_WORKSPACE}:${containerWorkspace}"
    ) {
        // export all dynamic env vars inside container
        sh """
            set -euo
            ${env.envExports}
        """
        body()
    }
}



// Helper for root user
def insideFlutterContainerRootUser(containerWorkspace, containerCache, body) {
    docker.image(env.FLUTTER_IMAGE).inside(
        "--user root " +
        "-v ${env.HOST_CACHE}:${containerCache} " +
        "-v ${env.HOST_WORKSPACE}:${containerWorkspace}"
    ) {
        sh """
            set -euo
            ${env.envExports}
        """
        body()
    }
}



pipeline {

    agent { label 'any' }

    parameters {
        booleanParam(name: 'DEEP_CLEAN_LIGHT', defaultValue: false, description: 'DEEP CLEAN LIGHT for release / deployement ?')
        booleanParam(name: 'DEEP_CLEAN_FULL', defaultValue: false, description: 'DEEP CLEAN FULL for complete clean of all caches. RUNTIME high!!')
        
        choice(
        name: 'BUILD_MODE',
        choices: ['debug', 'release'],
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


        // Static paths 

        // Flutter build container
        FLUTTER_IMAGE      = 'flutter_rust_env'

        // Host mount paths
        HOST_CACHE         = '/home/mirko/jenkins_host_cache'
        HOST_WORKSPACE     = '/home/mirko/jenkins_host_workspace'

        // GIT Home inside container
        HOME               = '/home/jenkins'

        // Flutter / Rust toolchains inside container
        FLUTTER_ROOT       = '/opt/flutter'
        RUSTUP_HOME        = '/opt/rust/rustup'
        CARGO_HOME         = '/opt/rust/cargo'
        RUST_CARGO_DIR     = '/opt/rust/cargo/bin'

        ANDROID_SDK_ROOT   = '/opt/android/sdk'
        ANDROID_NDK_HOME   = '/opt/android/sdk/ndk/28.2.13676358'
        ANDROID_NDK_TOOLCHAIN_DIR = '/opt/android/sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64/bin'

        // Gradle options
        GRADLE_OPTS        = "-Dorg.gradle.daemon=false -Dkotlin.daemon.enabled=false -Dkotlin.compiler.execution.strategy=in-process -Xmx1536m -Xms512m"

        // PATH definition (binaries only)
        PATH = "/opt/rust/cargo/bin:/opt/flutter/bin:/opt/android/sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64/bin:/opt/android/sdk/cmdline-tools/latest/bin:/opt/android/sdk/platform-tools:$PATH"
    }

    stages {


        stage('Setup Env') {
            steps {
                // Dynamic paths inside container (workspace-dependent)
                script {

                // now WORKSPACE exists
                env.CONTAINER_WORKSPACE = "${WORKSPACE}/jenkins_container_workspace"
                env.CONTAINER_CACHE     = "${WORKSPACE}/jenkins_container_cache"

                env.envExports = """

                    export HOME="${HOME}"

                    # Ephemeral workspace
                    export CONTAINER_WORKSPACE="${WORKSPACE}/jenkins_container_workspace"

                    # Persistent caches
                    export CONTAINER_CACHE="${WORKSPACE}/jenkins_container_cache"
                    export GRADLE_USER_HOME="${CONTAINER_CACHE}/.gradle"
                    export PUB_CACHE="${CONTAINER_CACHE}/.pub-cache"

                    # Flutter ephemeral build dirs
                    export FLUTTER_BUILD_DIRS_1="${CONTAINER_WORKSPACE}/build"
                    export FLUTTER_BUILD_DIRS_2="${CONTAINER_WORKSPACE}/android/build"
                    export FLUTTER_BUILD_DIRS_3="${CONTAINER_WORKSPACE}/.gradle"
                    export FLUTTER_BUILD_DIRS_4="${CONTAINER_WORKSPACE}/android/.gradle"

                    # Rust / Android FFI
                    export RUST_PROJECT_DIR="${CONTAINER_WORKSPACE}/rust/rust_lib"
                    export ANDROID_JNI_LIBS_DIR="${CONTAINER_WORKSPACE}/android/app/src/main/jniLibs"

                    # Toolchains
                    export FLUTTER_ROOT="${FLUTTER_ROOT}"
                    export RUSTUP_HOME="${RUSTUP_HOME}"
                    export CARGO_HOME="${CARGO_HOME}"
                    export RUST_CARGO_DIR="${RUST_CARGO_DIR}"
                    export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT}"
                    export ANDROID_NDK_HOME="${ANDROID_NDK_HOME}"
                    export ANDROID_NDK_TOOLCHAIN_DIR="${ANDROID_NDK_TOOLCHAIN_DIR}"

                    # Scripts (repo relative)
                    export INTEGRATION_TEST_SCRIPT="${CONTAINER_WORKSPACE}/scripts/run_integration_test.sh"
                    export PLANTUML_SCRIPT="${CONTAINER_WORKSPACE}/scripts/generate_PlantUML_PDF.ps1"
                    export SCRIPTS_DIR_CONTAINER="${CONTAINER_WORKSPACE}/scripts"

                """
                }
            }
        }


        stage('Setup Environment') {
            steps {
                script {
                    insideFlutterContainerJenkinsUser(
                    "${WORKSPACE}/jenkins_container_workspace",
                    "${WORKSPACE}/jenkins_container_cache") 
                    {
                    sh """

                        # Mandatory only in case child process use those variables
                        # Added for robustness only
                        ${envExports}
                        #################

                        # Create the required  directories inside the container
                        mkdir -p "${CONTAINER_WORKSPACE}" 
                        mkdir -p "${CONTAINER_CACHE}"
                        mkdir -p $HOME/.config/flutter

                        # Optional: verify the directories
                        echo "inside container:"
                        ls -la "${CONTAINER_WORKSPACE}"
                        ls -la "${CONTAINER_CACHE}"
                        ls -la "$HOME/.config"

                        # Optional: Run Flutter to verify it's all good
                        flutter --version

                    """
                    }
                }
            }
        }
        


        stage('Add GIT safe.directories') {
            steps {
                script {
                    insideFlutterContainerJenkinsUser(
                    "${WORKSPACE}/jenkins_container_workspace",
                    "${WORKSPACE}/jenkins_container_cache") 
                    {
                    sh """
                        set -euo

                        # Mandatory only in case child process use those variables
                        # Added for robustness only
                        ${envExports}
                        #################

                        git config --system --add safe.directory ${FLUTTER_ROOT}
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
                    "${WORKSPACE}/jenkins_container_workspace",
                    "${WORKSPACE}/jenkins_container_cache") 
                    {
                    sh """
                        bash -c '
                            set -Eeuo pipefail
                            trap "echo ❌ CI FAILED at line \$LINENO; exit 1" ERR

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

                            export HOME=${HOME}

                            section "CI SELF TEST"

                            require_env FLUTTER_ROOT
                            require_env RUST_CARGO_DIR
                            require_env RUSTUP_HOME
                            require_env CARGO_HOME
                            require_env ANDROID_SDK_ROOT
                            require_env ANDROID_NDK_HOME
                            require_env GRADLE_USER_HOME
                            require_env PUB_CACHE
                            require_env WORKSPACE
                            require_env CONTAINER_CACHE

                            section "Workspace & cache mounts"
                            check test -d "${CONTAINER_WORKSPACE}"
                            check test -w "${CONTAINER_WORKSPACE}"
                            check test -d "${CONTAINER_CACHE}"
                            check test -w "${CONTAINER_CACHE}"
                            echo "✅ Workspace & cache are mounted and writable"

                            section "Toolchain availability"
                            check command -v flutter
                            check command -v dart
                            check command -v cargo

                            flutter --version | head -n 1
                            cargo --version

                            section "Android SDK / NDK sanity"
                            check test -d "${ANDROID_SDK_ROOT}"
                            check test -d "${ANDROID_NDK_HOME}"
                            check test -d "${ANDROID_NDK_TOOLCHAIN_DIR}"
                            echo "✅ Android SDK & NDK OK"

                            section "Flutter doctor"
                            flutter doctor -v || true

                            echo "=============================="
                            echo "✅ CI SELF TEST PASSED"
                            echo "=============================="

                            sync || true
                            sleep 1
                        '
                    """
                    }
                }

            }
        }



        stage('Check Mount') {
            steps {
                script {                
                    insideFlutterContainerJenkinsUser(
                    "${WORKSPACE}/jenkins_container_workspace",
                    "${WORKSPACE}/jenkins_container_cache") 
                    {
                        sh """
                            # Mandatory only in case child process use those variables
                            # Added for robustness only
                            ${envExports}
                            #################

                            echo "Container Cache: ${CONTAINER_CACHE}" && ls -la "${CONTAINER_CACHE}" || echo "Cache empty"
                            echo "Container Workspace: ${CONTAINER_WORKSPACE}" && ls -la "${CONTAINER_WORKSPACE}" || echo "Cache empty"
                        """
                    }
                }
            }
        }



        stage('Verify Container Layout') {

            steps {
                script {                
                    insideFlutterContainerJenkinsUser(
                    "${WORKSPACE}/jenkins_container_workspace",
                    "${WORKSPACE}/jenkins_container_cache") 
                    {
                    sh """
                        set -euo
    
                        # Mandatory only in case child process use those variables
                        # Added for robustness only
                        ${envExports}
                        #################
    
                        echo "== Flutter =="
                        which flutter
                        flutter --version
    
                        echo "== Workspace =="
                        pwd
                        ls -la
    
                        echo "== Cache =="
                        ls -la ${CONTAINER_CACHE} || true
    
                        echo "== Env =="
                        env | sort
                    """
                    }
                }
            }
        }

        /*
        1. Stages before checkout:
        - Image existence
        - Container self-test

        2. ## CHECKOUT STAGE ##

        3. Stages after checkout:
        - Validate repo structure
        - Build
        */

        stage('Checkout') {
            steps {
                // Clean workspace on host
                cleanWs()

                script {                
                    insideFlutterContainerJenkinsUser(
                    "${WORKSPACE}/jenkins_container_workspace",
                    "${WORKSPACE}/jenkins_container_cache") 
                    {
                        checkout scm
                        sh """
                            ls -la
                        """
                    }
                }
            }
        }



        stage('Flutter → Android Materialization') {
            steps {
                script {                
                    insideFlutterContainerJenkinsUser(
                    "${WORKSPACE}/jenkins_container_workspace",
                    "${WORKSPACE}/jenkins_container_cache") 
                    {
                    sh """
                        # Mandatory only in case child process use those variables
                        # Added for robustness only
                        ${envExports}
                        #################

                        flutter pub get
                        flutter build apk --debug --no-shrink -v
                    """
                    }
                }
            }
        }


        stage('Gradle Deep Diagnostics') {

            steps {
                script {                
                    insideFlutterContainerJenkinsUser(
                    "${WORKSPACE}/jenkins_container_workspace",
                    "${WORKSPACE}/jenkins_container_cache") 
                    {
                    sh """
                        # Mandatory only in case child process use those variables
                        # Added for robustness only
                        ${envExports}
                        #################

                        cd android

                        ./gradlew -version
                        ./gradlew help \
                        --stacktrace \
                        --info \
                        --warning-mode=all \
                        --no-daemon

                        ./gradlew buildEnvironment
                    """
                    }
                }
            }
        }


        stage('Validate Repo Structure') {
            steps {
                script {                
                    insideFlutterContainerJenkinsUser(
                    "${WORKSPACE}/jenkins_container_workspace",
                    "${WORKSPACE}/jenkins_container_cache") 
                    {
                    // scripts directory (repo-relative)
                    if (!fileExists('scripts')) {
                        error "❌ scripts/ directory not found in repository"
                    }

                    // Flutter mandatory file
                    if (!fileExists('pubspec.yaml')) {
                        error "❌ pubspec.yaml missing"
                    }

                    // Optional but recommended
                    if (!fileExists('android')) {
                        error "❌ android/ directory missing"
                    }

                    echo "✅ Repository structure valid"
                    }
                }
            }
        }



        stage('Clean Environment Flutter') {
            // use Root agent to have permissions to delete all files
            steps {
                script {                
                    insideFlutterContainerRootUser(
                    "${WORKSPACE}/jenkins_container_workspace",
                    "${WORKSPACE}/jenkins_container_cache") 
                    {
                        echo "🧹 Cleaning Flutter build files"
                        sh """
                            set -euo

                        # Mandatory only in case child process use those variables
                        # Added for robustness only
                        ${envExports}
                        #################


                            # Flutter / Gradle build artifacts
                            rm -rf ${FLUTTER_BUILD_DIRS_1} \
                                    ${FLUTTER_BUILD_DIRS_2} \
                                    ${FLUTTER_BUILD_DIRS_3} \
                                    ${FLUTTER_BUILD_DIRS_4}

                            # Rust shared libraries
                            rm -rf ${ANDROID_JNI_LIBS_DIR}/* || true

                            # clean Rust target
                            if [ -d "${RUST_PROJECT_DIR}" ]; then
                                echo "🧹 Cleaning Rust build targets..."
                                cd "${RUST_PROJECT_DIR}"
                                cargo clean
                            else
                                echo "⚠️ Rust project not found, skipping Rust clean"
                            fi

                            # Fix ownership
                            chown -R 2000:2000 ${CONTAINER_WORKSPACE} ${CONTAINER_CACHE} || true
                        """
                    }
                }
            }
        }


        stage('Deep Clean LIGHT (For Deployment)') {
            when { expression { params.DEEP_CLEAN_LIGHT == true } }
            // use Root agent to have permissions to delete all files

            steps {
                script {                
                    insideFlutterContainerRootUser(
                    "${WORKSPACE}/jenkins_container_workspace",
                    "${WORKSPACE}/jenkins_container_cache") 
                    {
                    echo "☢️ Deep Clean LIGHT enabled"
                    sh """
                        set -euo

                        # Mandatory only in case child process use those variables
                        # Added for robustness only
                        ${envExports}
                        #################


                        # Flutter / Gradle caches
                        rm -rf ${GRADLE_USER_HOME}/caches/modules-* \
                               ${GRADLE_USER_HOME}/daemon \
                               ${PUB_CACHE}/hosted \
                               ${FLUTTER_ROOT}/bin/cache \
                               ${FLUTTER_BUILD_DIRS_1} \
                               ${FLUTTER_BUILD_DIRS_2} \
                               ${FLUTTER_BUILD_DIRS_3} \
                               ${FLUTTER_BUILD_DIRS_4}

                        # Rust libraries
                        rm -rf ${ANDROID_JNI_LIBS_DIR}/* || true
                        # clean Rust target
                        if [ -d "${RUST_PROJECT_DIR}" ]; then
                            echo "🧹 Cleaning Rust build targets..."
                            cd "${RUST_PROJECT_DIR}"
                            cargo clean
                        else
                            echo "⚠️ Rust project not found, skipping Rust clean"
                        fi

                        # Fix ownership
                        chown -R 2000:2000 ${CONTAINER_WORKSPACE} ${CONTAINER_CACHE} || true

                        echo "✅ Deep Clean LIGHT completed"
                    """
                    }
                }
            }
        }


        stage('Deep Clean FULL (Optional)') {
            when { expression { params.DEEP_CLEAN_FULL == true } }
            // use Root agent to have permissions to delete all files
            steps {
                script {                
                    insideFlutterContainerRootUser(
                    "${WORKSPACE}/jenkins_container_workspace",
                    "${WORKSPACE}/jenkins_container_cache") 
                    {
                    echo "☢️ Deep Clean FULL enabled"
                    sh """
                        set -euo

                        # Mandatory only in case child process use those variables
                        # Added for robustness only
                        ${envExports}
                        #################


                        # Flutter / Gradle caches
                        rm -rf ${GRADLE_USER_HOME}/caches \
                               ${GRADLE_USER_HOME}/daemon \
                               ${PUB_CACHE}/hosted \
                               ${PUB_CACHE}/git \
                               ${FLUTTER_ROOT}/bin/cache \
                               ${FLUTTER_BUILD_DIRS_1} \
                               ${FLUTTER_BUILD_DIRS_2} \
                               ${FLUTTER_BUILD_DIRS_3} \
                               ${FLUTTER_BUILD_DIRS_4}

                        # Rust build targets + shared libraries
                        rm -rf ${ANDROID_JNI_LIBS_DIR}/* || true
                        # clean Rust target
                        if [ -d "${RUST_PROJECT_DIR}" ]; then
                            echo "🧹 Cleaning Rust build targets..."
                            cd "${RUST_PROJECT_DIR}"
                            cargo clean
                        else
                            echo "⚠️ Rust project not found, skipping Rust clean"
                        fi

                        # Fix ownership
                        chown -R 2000:2000 ${WORKSPACE} ${CONTAINER_CACHE} || true

                        echo "✅ Deep Clean FULL completed"
                    """
                    }
                }
            }
        }



        stage('Build Rust (Android FFI)') {
            steps {
                script {                
                    insideFlutterContainerJenkinsUser(
                    "${WORKSPACE}/jenkins_container_workspace",
                    "${WORKSPACE}/jenkins_container_cache") 
                    {
                    echo "🦀 Building Rust backend for Android (FFI)"
                    sh """
                        set -euo

                        # Mandatory only in case child process use those variables
                        # Added for robustness only
                        ${envExports}
                        #################

                        cd "${RUST_PROJECT_DIR}"

                        echo "🧹 Cleaning previous Rust build"
                        cargo clean

                        echo "⚙️ Building Rust libraries via cargo-ndk"
                        cargo ndk \\
                          -t armeabi-v7a \\
                          -t arm64-v8a \\
                          -t x86_64 \\
                          -o ${ANDROID_JNI_LIBS_DIR} \\
                          build --release

                        echo "📦 Produced JNI libraries:"
                        find ${ANDROID_JNI_LIBS_DIR} -name "*.so"
                    """
                    }
                }
            }
        }


        stage('Build APK/AAB') {

            steps {
                script {     
                    insideFlutterContainerJenkinsUser(
                    "${WORKSPACE}/jenkins_container_workspace",
                    "${WORKSPACE}/jenkins_container_cache") 
                    {
                    echo "Building ${params.BUILD_MODE.toUpperCase()} APK/AAB"
                    sh """

                        # Mandatory only in case child process use those variables
                        # Added for robustness only
                        ${envExports}
                        #################

                        export GRADLE_OPTS="${GRADLE_OPTS}"

                        flutter pub get
                        flutter build apk --${params.BUILD_MODE}

                    """
                    }
                }
            }
        }


        stage('Run Integration Tests') {
            steps {
                script {                
                    insideFlutterContainerJenkinsUser(
                    "${WORKSPACE}/jenkins_container_workspace",
                    "${WORKSPACE}/jenkins_container_cache") 
                    {
                    sh """
                        set -euo

                        # Mandatory only in case child process use those variables
                        # Added for robustness only
                        ${envExports}
                        #################

                        ${INTEGRATION_TEST_SCRIPT}
                    """
                    }
                }
            }
        }

        stage('Generate Diagrams & PDF') {

            steps {
                script {                
                    insideFlutterContainerJenkinsUser(
                    "${WORKSPACE}/jenkins_container_workspace",
                    "${WORKSPACE}/jenkins_container_cache") 
                    {
                    sh "pwsh ${PLANTUML_SCRIPT}"
                    }
                }
            }
        }

        stage('Archive Artifacts') {

            steps {
                script {                
                    insideFlutterContainerJenkinsUser(
                    "${WORKSPACE}/jenkins_container_workspace",
                    "${WORKSPACE}/jenkins_container_cache") 
                    {
                    sh """
                        set -euo

                        mkdir -p build_outputs

                        find build -name "*.apk" -exec cp {} build_outputs/ \\; || true
                        find build -name "*.aab" -exec cp {} build_outputs/ \\; || true
                    """
                    archiveArtifacts artifacts: 'build_outputs/**', fingerprint: true, allowEmptyArchive: true
                    }
                }
            }
        }

        stage('Clean Workspace') {
            steps {
                script {                
                    insideFlutterContainerJenkinsUser(
                    "${WORKSPACE}/jenkins_container_workspace",
                    "${WORKSPACE}/jenkins_container_cache") 
                    {
                    cleanWs()
                    }
                }
            }
        }

    }

    post {
        success { echo "✅ Build succeeded" }
        failure { echo "❌ Build failed" }
    }

}