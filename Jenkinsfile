//  ------------------------------------------------------------
//  CI Workflow to build and push image to Docker Hub:
// 
//  GitHub → Jenkins (container) → docker run → flutter_rust_env (container)
//  
//  /var/jenkins_home   → Jenkins config
//  /workspace          → builds + @tmp
//  //  Jenkins pulls your app from GitHub into its workspace:
//
// Workspace is mounted into build container
//   -v $WORKSPACE:/sudoku_app    
//   
//   +---------------------------+
//   | Jenkins (Docker container)|
//   |  - UI / pipelines         |
//   |  - Workspace              |
//   +-------------+-------------+
//                 |
//                 | docker run
//                 v
//   +---------------------------+
//   | flutter_rust_env container|
//   |  - Flutter SDK            |
//   |  - Rust toolchain         |
//   |  - Builds APKs            |
//   +---------------------------+
//   
//   Host (WSL2)
//   ├── /home/mirko/jenkins_home_host_mount_workspace  ← Jenkins data
//   ├── Docker daemon
//   │   └── /var/run/docker.sock
//   │
//   └── Jenkins container
//       ├── /var/jenkins_home
//       └── /workspace  ← mounted
//       └── Docker CLI → host Docker
//
// Build artefacts are stored in :
//    /var/jenkins_home/jobs/Flutter_Docker_Pipeline/builds/<build-id>/archive/
// ------------------------------------------------------------

// Jenkins container
//   └── /var/jenkins_home
//   └── /workspace/Flutter_Docker_Pipeline
//         └── scripts/*.sh
//               │
//               └── mounted as
//                     ▼
// Flutter container
//   └── /sudoku_app/scripts/*.sh

// Windows
// └── WSL2 (Linux VM)
//     └── Docker Engine
//         ├── Jenkins container
//         │   └── /workspace/Flutter_Docker_Pipeline/  
//         │                                            └── <-- SOURCE CODE LIVES HERE
//         │
//         └── Flutter build container
//             └── /sudoku_app  (bind-mounted from Jenkins workspace)

//  ------------------------------------------------------------
//    Persist Jenkins data on the host machine:
//   -v /home/mirko/jenkins_home_host_mount:/var/jenkins_home
//   -v /home/mirko/jenkins_workspace_host_mount:/workspace
//   🚨 THIS IS THE MOST IMPORTANT LINE
//
//    docker mount command, https://docs.docker.com/engine/storage/bind-mounts/ : 
//       docker run -v <host-path>:<container-path>[:opts]
//       The $(pwd) sub-command expands to the current working directory on Linux
//
//   This is a bind mount:
//   Host (WSL2)	                                Container
//   /home/mirko/jenkins_home_host_mount	        /var/jenkins_home
//   /home/mirko/jenkins_workspace_host_mount	    /workspace

//   Comment : Jenkins is storing its workspaces under /var/jenkins_home by default 
//
//   -v (or --volume) bind-mounts a directory from your host into the container.
//   -v <host_path>:<container_path>
//
//   -w /sudoku_app — Working directory
//   -w (or --workdir) sets the current working directory inside the container.
//    Equivalent to running:
//    cd /sudoku_ap
//  ------------------------------------------------------------

//  ------------------------------------------------------------
//  Option:	                                            Purpose:
//  ------------------------------------------------------------
//  -d	                                                Run in background
//  --name jenkins_container_sudoku	                    Name the container
//  -p 8080:8080	                                    Jenkins web UI
//  -p 50000:50000	                                    Jenkins agents
//  -v …:/var/jenkins_home	                            Persist Jenkins data
//  -v …:/workspace	                                    Persist Jenkins build data
//  -v /var/run/docker.sock:/var/run/docker.sock	    Let Jenkins control Docker
//   jenkins_container_sudoku:lts	                    Jenkins image
//  ------------------------------------------------------------

//  ------------------------------------------------------------
//  different execution contexts, each with different users:
//  
//  - Host (WSL2 / Linux)
//  - Jenkins container
//  - Flutter build container
//  ------------------------------------------------------------

//  ------------------------------------------------------------
// RUN THE JENINS CONTAINER !! STEP 1/4
//  ------------------------------------------------------------
//
//  Prepare host directories for Jenkins home and workspace:
//  # Jenkins home
//  sudo mkdir -p /home/mirko/jenkins_home_host_mount
//  sudo chown -R 2000:2000 /home/mirko/jenkins_home_host_mount
//  sudo chmod -R 770 /home/mirko/jenkins_home_host_mount
//
//  # Jenkins workspace
//  sudo mkdir -p /home/mirko/jenkins_workspace_host_mount
//  sudo chown -R 2000:2000 /home/mirko/jenkins_workspace_host_mount
//  sudo chmod -R 770 /home/mirko/jenkins_workspace_host_mount
//
//  # Ordner für persistenten Cache auf dem Host
//  sudo mkdir -p /home/mirko/jenkins_cache
//  sudo chown -R 2000:2000 /home/mirko/jenkins_cache
//  sudo chmod -R 770 /home/mirko/jenkins_cache

// Docker compose build via your compose.yaml file
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
//     docker exec -it jenkins_sudoku_container bash
//  ------------------------------------------------------------

//  ------------------------------------------------------------
// RUN THE JENINS CONTAINER !! STEP 3/4
//  ------------------------------------------------------------
//   Print the initial admin password
//    cat /var/jenkins_home/secrets/initialAdminPassword
//    exit
// ------------------------------------------------------------

//  ------------------------------------------------------------
// RUN THE JENINS CONTAINER !! STEP 4/4
//  ------------------------------------------------------------
//   Jenkins in your browser:
//   http://localhost:8080
//
// Configure Jenkins pipeline in Jenkins GUI
// - Select GitHub, add repo github link
// - Select pipeline job
// - select path to jenkinsfile
//  ------------------------------------------------------------

pipeline {

    agent { label 'any' }

    parameters {
        booleanParam(name: 'DEEP_CLEAN_LIGHT', defaultValue: false, description: 'DEEP CLEAN LIGHT for release / deployement ?')
        booleanParam(name: 'DEEP_CLEAN_FULL', defaultValue: false, description: 'DEEP CLEAN FULL for complete clean of all caches. RUNTIME high!!')
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


        // Flutter build container
        FLUTTER_IMAGE           = 'flutter_rust_env'


        // Git home
        HOME                    = '/workspace/Flutter_Docker_Pipeline'

        // Container workspace mount path
        CONTAINER_WORKSPACE     = '/workspace/Flutter_Docker_Pipeline'


        //Host mount paths
        HOST_WORKSPACE          = '/home/mirko/jenkins_workspace_host_mount'
        HOST_CACHE              = '/home/mirko/jenkins_cache'


        // Rust related paths
        RUST_PROJECT_DIR        = '/workspace/Flutter_Docker_Pipeline/rust/rust_lib'
        ANDROID_JNI_LIBS_DIR    = '/workspace/Flutter_Docker_Pipeline/android/app/src/main/jniLibs'


        // Container cache mount path
        CONTAINER_CACHE         = '/workspace/cache'

        // Gradle / Pub cache : Container paths
        GRADLE_USER_HOME        = '/workspace/cache/.gradle'
        PUB_CACHE               = '/workspace/cache/.pub-cache'


        // Flutter
        FLUTTER_ROOT                = '/opt/flutter'

        // Rust
        RUSTUP_HOME                 = '/opt/rust/rustup'
        CARGO_HOME                  = '/opt/rust/cargo'
        RUST_CARGO_DIR              = '/opt/rust/cargo/bin'

        // SDK Root path
        ANDROID_SDK_ROOT            = '/opt/android/sdk'

        // NDK Home path
        ANDROID_NDK_HOME            = '/opt/android-ndk'
        ANDROID_NDK_TOOLCHAIN_DIR   = '/opt/android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin'


        DOCKER_AGENT_ARGS_JENKINS   = "-u 2000:2000 -v /home/mirko/jenkins_workspace_host_mount:/workspace/Flutter_Docker_Pipeline -v /home/mirko/jenkins_cache:/workspace/cache -w /workspace/Flutter_Docker_Pipeline"
        DOCKER_AGENT_ARGS_ROOT      = "-u 0:0 -v /home/mirko/jenkins_workspace_host_mount:/workspace/Flutter_Docker_Pipeline -v /home/mirko/jenkins_cache:/workspace/cache -w /workspace/Flutter_Docker_Pipeline"

        // Test scripts : 
        INTEGRATION_TEST_SCRIPT     = '/workspace/Flutter_Docker_Pipeline/scripts/run_integration_test.sh'
        PLANTUML_SCRIPT             = '/workspace/Flutter_Docker_Pipeline/scripts/generate_PlantUML_PDF.ps1'


        // -----------------------------
        // PATH defintion block
        // -----------------------------

        /* Binary paths that are added : 
 
        /opt/rust/cargo/bin
        /opt/flutter/bin
        /opt/android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin
        /opt/android/sdk/cmdline-tools/latest/bin
        /opt/android/sdk/platform-tools
        
        */
        PATH = "/opt/rust/cargo/bin:/opt/flutter/bin:/opt/android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin:/opt/android/sdk/cmdline-tools/latest/bin:/opt/android/sdk/platform-tools:$PATH"

    }


    stages {

        stage('Add GIT safe.directories') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_ROOT}"
                }
            }
                        steps {
                sh """
                    set -e

                    git config --system --add safe.directory ${FLUTTER_ROOT}
                """
            }
        }


        stage('CI Self-Test') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_JENKINS}"
                }
            }
            steps {
                echo "🧪 Running CI Self-Test (fail-fast)"

                sh """

                    set -e

                    echo "=============================="
                    echo "🧪 CI SELF TEST"
                    echo "=============================="


                    export GRADLE_USER_HOME=${GRADLE_USER_HOME}
                    export PUB_CACHE=${PUB_CACHE}
                    export RUST_CARGO_DIR=${RUST_CARGO_DIR}

                    # -----------------------------
                    # 1. Required ENV variables
                    # -----------------------------


                    if [ -z "${FLUTTER_ROOT}" ];        then echo "❌ Missing ENV variable: FLUTTER_ROOT";          exit 1; fi
                    if [ -z "${RUST_CARGO_DIR}" ];      then echo "❌ Missing ENV variable: RUST_CARGO_DIR";        exit 1; fi
                    if [ -z "${RUSTUP_HOME}" ];         then echo "❌ Missing ENV variable: RUSTUP_HOME";           exit 1; fi
                    if [ -z "${CARGO_HOME}" ];          then echo "❌ Missing ENV variable: CARGO_HOME";            exit 1; fi                    
                    if [ -z "${ANDROID_SDK_ROOT}" ];    then echo "❌ Missing ENV variable: ANDROID_SDK_ROOT";      exit 1; fi
                    if [ -z "${ANDROID_NDK_HOME}" ];    then echo "❌ Missing ENV variable: ANDROID_NDK_HOME";      exit 1; fi
                    if [ -z "${GRADLE_USER_HOME}" ];    then echo "❌ Missing ENV variable: GRADLE_USER_HOME";      exit 1; fi
                    if [ -z "${PUB_CACHE}" ];           then echo "❌ Missing ENV variable: PUB_CACHE";             exit 1; fi
                    if [ -z "${CONTAINER_WORKSPACE}" ]; then echo "❌ Missing ENV variable: CONTAINER_WORKSPACE";   exit 1; fi
                    if [ -z "${CONTAINER_CACHE}" ];     then echo "❌ Missing ENV variable: CONTAINER_CACHE";       exit 1; fi


                    # -----------------------------
                    # 2. Workspace & cache mounts
                    # -----------------------------
                    test -d "${CONTAINER_WORKSPACE}"
                    test -w "${CONTAINER_WORKSPACE}"
                    test -d "${CONTAINER_CACHE}"
                    test -w "${CONTAINER_CACHE}"
                    echo "✅ Workspace & cache are mounted and writable"

                    # -----------------------------
                    # 3. Toolchain availability
                    # -----------------------------
                    command -v flutter >/dev/null || { echo "❌ flutter missing"; exit 1; }
                    command -v dart >/dev/null || { echo "❌ dart missing"; exit 1; }
                    command -v cargo >/dev/null || { echo "❌ cargo missing"; exit 1; }

                    flutter --version | head -n 1
                    cargo --version

                    # -----------------------------
                    # 4. Android SDK / NDK sanity
                    # -----------------------------
                    test -d "${ANDROID_SDK_ROOT}"
                    test -d "${ANDROID_NDK_HOME}"
                    test -x "${ANDROID_NDK_TOOLCHAIN_DIR}/clang" || { echo "❌ NDK clang not found"; exit 1; }

                    echo "✅ Android SDK & NDK OK"

                    # -----------------------------
                    # 5. Flutter doctor (CI-safe)
                    # -----------------------------
                    flutter doctor -v || true

                    echo "=============================="
                    echo "✅ CI SELF TEST PASSED"
                    echo "=============================="
                    """
            }
        }



        stage('Check Mount') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_JENKINS}"
                }
            }
            steps {

                sh 'echo "Container Workspace: $CONTAINER_WORKSPACE" && ls -la $CONTAINER_WORKSPACE'
                sh 'echo "Container Cache: $CONTAINER_CACHE" && ls -la $CONTAINER_CACHE || echo "Cache empty"'
            }
        }


        stage('Verify Container Layout') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_JENKINS}"
                }
            }
            steps {
                sh """
                    set -e

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


        stage('Checkout') {
            agent { label 'any' }
            steps {
                cleanWs()
                checkout scm
                sh 'ls -la'
            }
        }


        stage('Validate Repo Structure') {
            agent { label 'any' }
            steps {
                script {
                    if (!fileExists("${SCRIPTS_DIR}")) {
                        error "❌ scripts directory not found"
                    } else {
                        echo "✅ scripts directory exists"
                    }
                }
            }
        }


        stage('Clean Environment Flutter') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_ROOT}"
                }
            }
            steps {
                echo "🧹 Cleaning Flutter build files"
                sh """
                    set -e

                    export GRADLE_USER_HOME=${GRADLE_USER_HOME}
                    export PUB_CACHE=${PUB_CACHE}

                    # Flutter / Gradle build artifacts
                    rm -rf ${FLUTTER_BUILD_DIRS}

                    # Rust shared libraries
                    rm -rf ${ANDROID_JNI_LIBS_DIR}/* || true

                    # clean Rust target
                    if [ -d "${CRUST_PROJECT_DIR}" ]; then
                        echo "🧹 Cleaning Rust build targets..."
                        cd "${CRUST_PROJECT_DIR}"
                        cargo clean
                    else
                        echo "⚠️ Rust project not found, skipping Rust clean"
                    fi

                    # Fix ownership
                    chown -R 2000:2000 ${CONTAINER_WORKSPACE} ${CONTAINER_CACHE} || true
                """
            }
        }


        stage('Deep Clean LIGHT (For Deployment)') {
            when { expression { params.DEEP_CLEAN_LIGHT == true } }
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_ROOT}"
                }
            }
            steps {
                echo "☢️ Deep Clean LIGHT enabled"
                sh """
                    set -e
                    export GRADLE_USER_HOME=${GRADLE_USER_HOME}
                    export PUB_CACHE=${PUB_CACHE}
                    export RUST_CARGO_DIR=${RUST_CARGO_DIR}

                    # Flutter / Gradle caches
                    rm -rf ${GRADLE_USER_HOME}/caches/modules-* \
                           ${GRADLE_USER_HOME}/daemon \
                           ${PUB_CACHE}/hosted \
                           ${FLUTTER_ROOT}/bin/cache \
                           ${FLUTTER_BUILD_DIRS}

                    # Rust libraries
                    rm -rf ${ANDROID_JNI_LIBS_DIR}/* || true
                    # clean Rust target
                    if [ -d "${CRUST_PROJECT_DIR}" ]; then
                        echo "🧹 Cleaning Rust build targets..."
                        cd "${CRUST_PROJECT_DIR}"
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


        stage('Deep Clean FULL (Optional)') {
            when { expression { params.DEEP_CLEAN_FULL == true } }
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_ROOT}"
                }
            }
            steps {
                echo "☢️ Deep Clean FULL enabled"
                sh """
                    set -e
                    export GRADLE_USER_HOME=${GRADLE_USER_HOME}
                    export PUB_CACHE=${PUB_CACHE}

                    # Flutter / Gradle caches
                    rm -rf ${GRADLE_USER_HOME}/caches \
                           ${GRADLE_USER_HOME}/daemon \
                           ${PUB_CACHE}/hosted \
                           ${PUB_CACHE}/git \
                           ${FLUTTER_ROOT}/bin/cache \
                           ${FLUTTER_BUILD_DIRS}

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
                    chown -R 2000:2000 ${CONTAINER_WORKSPACE} ${CONTAINER_CACHE} || true

                    echo "✅ Deep Clean FULL completed"
                """
            }
        }


        stage('Build Rust (Android FFI)') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_JENKINS}"
                }
            }
            steps {
                echo "🦀 Building Rust backend for Android (FFI)"
                sh """
                    set -e

                    export ANDROID_JNI_LIBS_DIR =   ${ANDROID_JNI_LIBS_DIR}
                    export RUST_PROJECT_DIR     =   ${RUST_PROJECT_DIR}

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



        stage('Build debug APK/AAB') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_JENKINS}"
                }
            }
            steps {
                sh """
                    set -e
                    export GRADLE_USER_HOME=${GRADLE_USER_HOME}
                    export PUB_CACHE=${PUB_CACHE}

                    flutter pub get
                    flutter build apk --debug --no-daemon
                """
            }
        }

        stage('Build release APK/AAB') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_JENKINS}"
                }
            }
            steps {
                sh """
                    set -e
                    export GRADLE_USER_HOME=${GRADLE_USER_HOME}
                    export PUB_CACHE=${PUB_CACHE}

                    flutter pub get
                    flutter build apk --release --no-daemon
                """
            }
        }

        stage('Run Integration Tests') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_JENKINS}"
                }
            }
            steps {
                sh """
                    set -e
                    ${INTEGRATION_TEST_SCRIPT}
                """
            }
        }

        stage('Generate Diagrams & PDF') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_JENKINS}"
                }
            }
            steps {
                sh "pwsh ${PLANTUML_SCRIPT}"
            }
        }

        stage('Archive Artifacts') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_JENKINS}"
                }
            }
            steps {
                sh """
                    set -e
                    mkdir -p build_outputs

                    find build -name "*.apk" -exec cp {} build_outputs/ \\; || true
                    find build -name "*.aab" -exec cp {} build_outputs/ \\; || true
                """
                archiveArtifacts artifacts: 'build_outputs/**', fingerprint: true, allowEmptyArchive: true
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success { echo "✅ Build succeeded" }
        failure { echo "❌ Build failed" }
    }
}
