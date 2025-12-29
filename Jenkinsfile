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
        booleanParam(name: 'DEEP_CLEAN', defaultValue: false, description: 'Perform a full Flutter + Gradle cache clean?')
    }

    options {
        skipDefaultCheckout true
    }

    environment {
        // Flutter build container
        FLUTTER_IMAGE       = 'flutter_rust_env'

        // Workspace : Host/ Container mount paths
        HOST_WORKSPACE      = '/home/mirko/jenkins_workspace_host_mount'
        CONTAINER_WORKSPACE = '/workspace/Flutter_Docker_Pipeline'

        // Cache :  Container mount paths
        HOST_CACHE          = '/home/mirko/jenkins_cache'
        CONTAINER_CACHE     = '/workspace/cache'


        // Gradle / Pub cache : Container paths
        GRADLE_USER_HOME    = "${CONTAINER_CACHE}/.gradle"
        PUB_CACHE           = "${CONTAINER_CACHE}/.pub-cache"

        // Flutter
        FLUTTER_ROOT        = '/opt/flutter'
        PATH                = "${FLUTTER_ROOT}/bin:${env.PATH}"

        // GIT home
        HOME = "${CONTAINER_WORKSPACE}"

        // Repository paths
        SCRIPTS_DIR = 'scripts'

        CLEAN_GRADLE_SCRIPT     = "${SCRIPTS_DIR}/clean_gradle_cache.sh"
        CLEAN_FLUTTER_SCRIPT    = "${SCRIPTS_DIR}/clean_flutter.sh"
        BUILD_ALL_SCRIPT        = "${SCRIPTS_DIR}/build_all.sh"
        BUILD_DEBUG_ARGS        = 'debug'
        BUILD_RELEASE_ARGS      = 'release'
        INTEGRATION_TEST_SCRIPT = "${SCRIPTS_DIR}/run_integration_test.sh"
        PLANTUML_SCRIPT         = "${SCRIPTS_DIR}/generate_PlantUML_PDF.ps1"

        // Docker args
        DOCKER_AGENT_ARGS_JENKINS = "-u 2000:2000 -v ${HOST_WORKSPACE}:${CONTAINER_WORKSPACE} -v ${HOST_CACHE}:${CONTAINER_CACHE} -w ${CONTAINER_WORKSPACE}"
        DOCKER_AGENT_ARGS_ROOT    = "-u 0:0 -v ${HOST_WORKSPACE}:${CONTAINER_WORKSPACE} -v ${HOST_CACHE}:${CONTAINER_CACHE} -w ${CONTAINER_WORKSPACE}"
    }

    stages {

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
                    git config --system --add safe.directory /opt/flutter
                """
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
                    ls -la /workspace/cache || true

                    echo "== Env =="
                    env | sort
                """
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

                    rm -rf .gradle android/.gradle build android/build

                    echo "Ownership before fix:"
                    ls -ld ${CONTAINER_WORKSPACE} ${CONTAINER_CACHE}

                    chown -R 2000:2000 ${CONTAINER_WORKSPACE} ${CONTAINER_CACHE}

                    echo "Ownership after fix:"
                    ls -ld ${CONTAINER_WORKSPACE} ${CONTAINER_CACHE}
                """
            }
        }

        stage('Deep Clean (Optional)') {
            when { expression { params.DEEP_CLEAN == true } }
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_ROOT}"
                }
            }
            steps {
                echo "☢️ DEEP CLEAN ENABLED"
                sh """
                    set -e
                    export GRADLE_USER_HOME=${GRADLE_USER_HOME}
                    export PUB_CACHE=${PUB_CACHE}

                    rm -rf \
                      ${GRADLE_USER_HOME}/caches \
                      ${GRADLE_USER_HOME}/daemon \
                      ${PUB_CACHE} \
                      ${FLUTTER_ROOT}/bin/cache || true

                    chown -R 2000:2000 ${CONTAINER_WORKSPACE} ${CONTAINER_CACHE}

                    echo "✅ Deep clean completed"
                """
                /*
                sh """
                            set -e
                            echo "🧹 Cleaning Flutter and Gradle caches"

                            echo "🧹 Cleaning Flutter caches"
                            ${CLEAN_GRADLE_SCRIPT}

                            echo "🧹 Cleaning Gradle caches"
                            ${CLEAN_FLUTTER_SCRIPT}

                """
                */
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
                    flutter build apk --debug
                """
                /*
                sh """
                    set -e
                    echo "Build debug APK/AAB"
                    ${BUILD_ALL_SCRIPT} ${BUILD_DEBUG_ARGS}
                """
                */
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
                    flutter build apk --release
                """
                /*
                sh """
                    set -e
                    echo "Build release APK/AAB"
                    ${BUILD_ALL_SCRIPT} ${BUILD_RELEASE_ARGS}
                """
                */

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
