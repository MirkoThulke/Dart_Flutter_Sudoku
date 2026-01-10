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
//  # Ordner für persistenten Cache auf dem Host
//  sudo mkdir -p /home/mirko/jenkins_cache
//  sudo chown -R 2000:2000 /home/mirko/jenkins_cache
//  sudo chmod -R 770 /home/mirko/jenkins_cache
//
//  # Jenkins Rust workspace on Host
//  sudo mkdir -p /workspace/Flutter_Docker_Pipeline/rust/rust_lib
//  sudo chown -R 2000:2000 /workspace/Flutter_Docker_Pipeline/rust/rust_lib
//  sudo chmod -R 770 /workspace/Flutter_Docker_Pipeline/rust/rust_lib



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


        // Flutter build container
        FLUTTER_IMAGE           = 'flutter_rust_env'


        //Host mount paths
        HOST_CACHE              = '/home/mirko/jenkins_cache'
        HOST_WORKSPACE          = '/home/mirko/jenkins_workspace_host_mount'

        // GIT Home 
        HOME                    = '/home/jenkins'

        // Rust related paths
        RUST_PROJECT_DIR        = '${WORKSPACE}/rust/rust_lib'
        ANDROID_JNI_LIBS_DIR    = '${WORKSPACE}/android/app/src/main/jniLibs'


        // Container cache mount path
        CONTAINER_CACHE         = '${WORKSPACE}/cache'
        CONTAINER_WORKSPACE     = '${WORKSPACE}/jenkins_workspace_container'

        // -----------------------------
        // Container cache paths
        // -----------------------------
        GRADLE_USER_HOME = '${WORKSPACE}/cache/.gradle'
        PUB_CACHE        = '${WORKSPACE}/cache/.pub-cache'


        // Flutter
        FLUTTER_ROOT                = '/opt/flutter'
        
        // Flutter build artefacts
        FLUTTER_BUILD_DIRS_1        = '${WORKSPACE}/.gradle' 
        FLUTTER_BUILD_DIRS_2        = '${WORKSPACE}/android/.gradle' 
        FLUTTER_BUILD_DIRS_3        = '${WORKSPACE}/build' 
        FLUTTER_BUILD_DIRS_4        = '${WORKSPACE}/android/build'


        // Rust
        RUSTUP_HOME                 = '/opt/rust/rustup'
        CARGO_HOME                  = '/opt/rust/cargo'
        RUST_CARGO_DIR              = '/opt/rust/cargo/bin'

        ANDROID_SDK_ROOT            = '/opt/android/sdk'


        // NDK Home path
        ANDROID_NDK_HOME            = '/opt/android/sdk/ndk/28.2.13676358'
        ANDROID_NDK_TOOLCHAIN_DIR   = '/opt/android/sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64/bin'


        DOCKER_AGENT_ARGS_JENKINS   = "-v /home/mirko/jenkins_cache:${WORKSPACE}/cache -v /home/mirko/jenkins_home_host_mount:/home/jenkins"
        DOCKER_AGENT_ARGS_ROOT      = "--user root -v /home/mirko/jenkins_cache:${WORKSPACE}/cache -v /home/mirko/jenkins_home_host_mount:/home/jenkins"

        // Gradle options
        GRADLE_OPTS                 ="-Dorg.gradle.daemon=false \
                                        -Dkotlin.daemon.enabled=false \
                                        -Dkotlin.compiler.execution.strategy=in-process \
                                        -Xmx1536m -Xms512m"
                                        // Disables Gradle daemon at runtime
                                        // Disables Kotlin compiler daemon
                                        // Forces in-process Kotlin compilation

        // Test scripts : 
        INTEGRATION_TEST_SCRIPT     = '${WORKSPACE}/scripts/run_integration_test.sh'
        PLANTUML_SCRIPT             = '${WORKSPACE}/scripts/generate_PlantUML_PDF.ps1'

        // Other scripts:
        SCRIPTS_DIR_CONTAINER       = '${WORKSPACE}/scripts'


        // -----------------------------
        // PATH defintion block
        // -----------------------------

        /* Binary paths that are added : 
 
        /opt/rust/cargo/bin
        /opt/flutter/bin
        /opt/android/sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64/bin
        /opt/android/sdk/cmdline-tools/latest/bin
        /opt/android/sdk/platform-tools
        
        */
        PATH = "/opt/rust/cargo/bin:/opt/flutter/bin:/opt/android/sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64/bin:/opt/android/sdk/cmdline-tools/latest/bin:/opt/android/sdk/platform-tools:$PATH"

    }


    stages {


        stage('Setup Environment') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_JENKINS}"
                }
            }
            steps {
                script {
                    sh """

                        export HOME=${HOME}
                        export WORKSPACE=${WORKSPACE}
                        export CONTAINER_CACHE=${CONTAINER_CACHE}

                        # Create the required  directories inside the container
                        mkdir -p "${WORKSPACE}" 
                        mkdir -p "${CONTAINER_CACHE}"
                        mkdir -p $HOME/.config/flutter

                        # Optional: verify the directories
                        echo "inside container:"
                        ls -la "${WORKSPACE}"
                        ls -la "${CONTAINER_CACHE}"
                        ls -la $HOME/.config

                        # Optional: Run Flutter to verify it's all good
                        flutter --version

                    """
                }
            }
        }


        stage('Add GIT safe.directories') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_ROOT}"
                }
            }
            steps {
                sh """
                    set -euo

                    # export to git child process required
                    export FLUTTER_ROOT="${FLUTTER_ROOT}"
                    export HOME=${HOME}

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
                        check test -d "${WORKSPACE}"
                        check test -w "${WORKSPACE}"
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



        stage('Check Mount') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_JENKINS}"
                }
            }
            steps {

                sh 'echo "Container Cache: $CONTAINER_CACHE" && ls -la $CONTAINER_CACHE || echo "Cache empty"'
                sh 'echo "Container Cache: $CONTAINER_WORKSPACE" && ls -la $CONTAINER_WORKSPACE || echo "Cache empty"'
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
                    set -euo

                    # Mandatory only in case child process use those variables
                    # Added for robustness only
                    export CONTAINER_CACHE=${CONTAINER_CACHE}
                    export HOME=${HOME}

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

        /*
        Stages before checkout:
        - Image existence
        - Container self-test

        Stages after checkout:
        - Validate repo structure
        - Build
        */

        stage('Checkout') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_JENKINS}"
                }
            }
            steps {
                cleanWs()
                checkout scm
                sh 'ls -la'
            }
        }


        stage('Validate Repo Structure') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_JENKINS}"
                }
            }
            steps {
                script {
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
                    set -euo

                    # Mandatory only in case child process use those variables
                    # Added for robustness only
                    export FLUTTER_BUILD_DIRS_1=${FLUTTER_BUILD_DIRS_1}
                    export FLUTTER_BUILD_DIRS_2=${FLUTTER_BUILD_DIRS_2}
                    export FLUTTER_BUILD_DIRS_3=${FLUTTER_BUILD_DIRS_3}
                    export FLUTTER_BUILD_DIRS_4=${FLUTTER_BUILD_DIRS_4}
                    export ANDROID_JNI_LIBS_DIR=${ANDROID_JNI_LIBS_DIR}
                    export RUST_PROJECT_DIR=${RUST_PROJECT_DIR}
                    export WORKSPACE=${WORKSPACE}
                    export CONTAINER_CACHE=${CONTAINER_CACHE}
                    export HOME=${HOME}


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
                    set -euo

                    # Mandatory only in case child process use those variables
                    # Added for robustness only
                    export GRADLE_USER_HOME=${GRADLE_USER_HOME}
                    export PUB_CACHE=${PUB_CACHE}
                    export FLUTTER_ROOT=${FLUTTER_ROOT}
                    export FLUTTER_BUILD_DIRS_1=${FLUTTER_BUILD_DIRS_1}
                    export FLUTTER_BUILD_DIRS_2=${FLUTTER_BUILD_DIRS_2}
                    export FLUTTER_BUILD_DIRS_3=${FLUTTER_BUILD_DIRS_3}
                    export FLUTTER_BUILD_DIRS_4=${FLUTTER_BUILD_DIRS_4}
                    export ANDROID_JNI_LIBS_DIR=${ANDROID_JNI_LIBS_DIR}
                    export RUST_PROJECT_DIR=${RUST_PROJECT_DIR}
                    export WORKSPACE=${CONTAINER_WORKSPACE}
                    export CONTAINER_CACHE=${CONTAINER_CACHE}
                    export HOME=${HOME}


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
                    chown -R 2000:2000 ${WORKSPACE} ${CONTAINER_CACHE} || true

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
                    set -euo

                    # Mandatory only in case child process use those variables
                    # Added for robustness only
                    export GRADLE_USER_HOME=${GRADLE_USER_HOME}
                    export PUB_CACHE=${PUB_CACHE}
                    export FLUTTER_ROOT=${FLUTTER_ROOT}
                    export FLUTTER_BUILD_DIRS_1=${FLUTTER_BUILD_DIRS_1}
                    export FLUTTER_BUILD_DIRS_2=${FLUTTER_BUILD_DIRS_2}
                    export FLUTTER_BUILD_DIRS_3=${FLUTTER_BUILD_DIRS_3}
                    export FLUTTER_BUILD_DIRS_4=${FLUTTER_BUILD_DIRS_4}
                    export ANDROID_JNI_LIBS_DIR=${ANDROID_JNI_LIBS_DIR}
                    export RUST_PROJECT_DIR=${RUST_PROJECT_DIR}
                    export WORKSPACE=${WORKSPACE}
                    export CONTAINER_CACHE=${CONTAINER_CACHE}
                    export HOME=${HOME}


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

        stage('Verify the workspace layout') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_JENKINS}"
                }
            }
            steps {
                sh """
                    pwd
                    ls -la
                """
            }
        }


        stage('Flutter Bootstrap') {
            steps {
                sh '''
                    flutter pub get
                '''
            }
        }


        stage('Gradle Sanity Check') {
                    agent {
                        docker {
                            image "${FLUTTER_IMAGE}"
                            args "${DOCKER_AGENT_ARGS_JENKINS}"
                        }
                    }
                    steps {
                                dir('android') {
                                    sh '''
                                            chmod +x gradlew
                                            ./gradlew help --no-daemon
                                        '''
                                }
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
                    set -euo

                    # Mandatory only in case child process use those variables
                    # Added for robustness only
                    export GRADLE_USER_HOME=${GRADLE_USER_HOME}
                    export PUB_CACHE=${PUB_CACHE}
                    export FLUTTER_ROOT=${FLUTTER_ROOT}
                    export FLUTTER_BUILD_DIRS_1=${FLUTTER_BUILD_DIRS_1}
                    export FLUTTER_BUILD_DIRS_2=${FLUTTER_BUILD_DIRS_2}
                    export FLUTTER_BUILD_DIRS_3=${FLUTTER_BUILD_DIRS_3}
                    export FLUTTER_BUILD_DIRS_4=${FLUTTER_BUILD_DIRS_4}
                    export ANDROID_JNI_LIBS_DIR=${ANDROID_JNI_LIBS_DIR}
                    export RUST_PROJECT_DIR=${RUST_PROJECT_DIR}
                    export WORKSPACE=${WORKSPACE}
                    export CONTAINER_CACHE=${CONTAINER_CACHE}
                    export RUSTUP_HOME=${RUSTUP_HOME}
                    export CARGO_HOME=${CARGO_HOME}
                    export RUST_CARGO_DIR=${RUST_CARGO_DIR}
                    export ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT}
                    export ANDROID_NDK_HOME=${ANDROID_NDK_HOME}
                    export ANDROID_NDK_TOOLCHAIN_DIR=${ANDROID_NDK_TOOLCHAIN_DIR}
                    export HOME=${HOME}
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


        stage('Build APK/AAB') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_JENKINS}"
                }
            }
            steps {
                script {
                    echo "Building ${params.BUILD_MODE.toUpperCase()} APK/AAB"
                    sh """

                        # Mandatory only in case child process use those variables
                        # Added for robustness only
                        export GRADLE_USER_HOME=${GRADLE_USER_HOME}
                        export PUB_CACHE=${PUB_CACHE}
                        export FLUTTER_ROOT=${FLUTTER_ROOT}
                        export FLUTTER_BUILD_DIRS_1=${FLUTTER_BUILD_DIRS_1}
                        export FLUTTER_BUILD_DIRS_2=${FLUTTER_BUILD_DIRS_2}
                        export FLUTTER_BUILD_DIRS_3=${FLUTTER_BUILD_DIRS_3}
                        export FLUTTER_BUILD_DIRS_4=${FLUTTER_BUILD_DIRS_4}
                        export ANDROID_JNI_LIBS_DIR=${ANDROID_JNI_LIBS_DIR}
                        export RUST_PROJECT_DIR=${RUST_PROJECT_DIR}
                        export WORKSPACE=${WORKSPACE}
                        export CONTAINER_CACHE=${CONTAINER_CACHE}
                        export RUSTUP_HOME=${RUSTUP_HOME}
                        export CARGO_HOME=${CARGO_HOME}
                        export RUST_CARGO_DIR=${RUST_CARGO_DIR}
                        export ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT}
                        export ANDROID_NDK_HOME=${ANDROID_NDK_HOME}
                        export ANDROID_NDK_TOOLCHAIN_DIR=${ANDROID_NDK_TOOLCHAIN_DIR}
                        export HOME=${HOME}
                        ################# 

                        export GRADLE_OPTS="${GRADLE_OPTS}"
                        flutter pub get
                        flutter build apk --${params.BUILD_MODE}

                    """
                }
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
                    set -euo

                    # Mandatory only in case child process use those variables
                    # Added for robustness only
                    export GRADLE_USER_HOME=${GRADLE_USER_HOME}
                    export PUB_CACHE=${PUB_CACHE}
                    export FLUTTER_ROOT=${FLUTTER_ROOT}
                    export FLUTTER_BUILD_DIRS_1=${FLUTTER_BUILD_DIRS_1}
                    export FLUTTER_BUILD_DIRS_2=${FLUTTER_BUILD_DIRS_2}
                    export FLUTTER_BUILD_DIRS_3=${FLUTTER_BUILD_DIRS_3}
                    export FLUTTER_BUILD_DIRS_4=${FLUTTER_BUILD_DIRS_4}
                    export ANDROID_JNI_LIBS_DIR=${ANDROID_JNI_LIBS_DIR}
                    export RUST_PROJECT_DIR=${RUST_PROJECT_DIR}
                    export WORKSPACE=${WORKSPACE}
                    export CONTAINER_CACHE=${CONTAINER_CACHE}
                    export RUSTUP_HOME=${RUSTUP_HOME}
                    export CARGO_HOME=${CARGO_HOME}
                    export RUST_CARGO_DIR=${RUST_CARGO_DIR}
                    export ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT}
                    export ANDROID_NDK_HOME=${ANDROID_NDK_HOME}
                    export ANDROID_NDK_TOOLCHAIN_DIR=${ANDROID_NDK_TOOLCHAIN_DIR}
                    export HOME=${HOME}
                    #################

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
                    set -euo
                    
                    mkdir -p build_outputs

                    find build -name "*.apk" -exec cp {} build_outputs/ \\; || true
                    find build -name "*.aab" -exec cp {} build_outputs/ \\; || true
                """
                archiveArtifacts artifacts: 'build_outputs/**', fingerprint: true, allowEmptyArchive: true
            }
        }

        stage('Clean Workspace') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_JENKINS}"
                }
            }
            steps {
                sh 'rm -rf ${WORKSPACE}/*'
            }
        }

    }

    post {

        success { echo "✅ Build succeeded" }
        failure { echo "❌ Build failed" }

    }
}
