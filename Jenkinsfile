//  ------------------------------------------------------------
//  CI Workflow to build and push image to Docker Hub:
// 
//  GitHub → Jenkins (container) → docker run → flutter_rust_env (container)
//  
//  Jenkins pulls your app from GitHub into its workspace:
//    /var/jenkins_home/workspace/Flutter_Docker_Pipeline
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
//   ├── /mnt/wsl/jenkins_home_host_mount  ← Jenkins data
//   ├── Docker daemon
//   │   └── /var/run/docker.sock
//   │
//   └── Jenkins container
//       ├── /var/jenkins_home  ← mounted
//       └── Docker CLI → host Docker
//
// Build artefacts are stored in :
//    /var/jenkins_home/jobs/Flutter_Docker_Pipeline/builds/<build-id>/archive/
// ------------------------------------------------------------

// Jenkins container
//   └── /var/jenkins_home/workspace/Flutter_Docker_Pipeline
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
//
//   -v /var/jenkins_home_host_mount:/var/jenkins_home
//   🚨 THIS IS THE MOST IMPORTANT LINE
//
//    docker mount command, https://docs.docker.com/engine/storage/bind-mounts/ : 
//       docker run -v <host-path>:<container-path>[:opts]
//       The $(pwd) sub-command expands to the current working directory on Linux
//
//   This is a bind mount:
//   Host (WSL2)	                                Container
//   /mnt/wsl/jenkins_home_host_mount	    /var/jenkins_home
//   
//   Jenkins is storing its workspaces under /var/jenkins_home by default 
//   (including the Flutter_Docker_Pipeline workspace)
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
// Run Jenkins container with:

//   sudo mkdir -p /var/jenkins_home_host_mount
//   sudo rm -rf /var/jenkins_home_host_mount/*
//   sudo chown -R 2000:2000 /var/jenkins_home_host_mount/
//   sudo chmod -R 755 /var/jenkins_home_host_mount/
//
// Docker container creation with command line is handled via docker compose file:
//
//   option a) 
//     /home/mirko/sudoku/jenkins docker run -d --name jenkins_sudoku_container --restart unless-stopped -e TZ=Europe/Paris -p 8080:8080 -p 50000:50000 -v /var/jenkins_home_host_mount:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins_sudoku_image:2.528.3
//
//   option b)
//     /home/mirko/sudoku/jenkins/docker compose up -d --build
//     /home/mirko/sudoku/jenkinsdocker compose down
//     /home/mirko/sudoku/jenkins/docker compose logs -f
//     /home/mirko/sudoku/jenkins/docker compose ps
//
//  Check ownership and permissions of the Jenkins workspace:
//   ls -ld /var/jenkins_home_host_mount
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
    agent any
    options {
        skipDefaultCheckout true
    }

    environment {
        // Global workspace path (custom)
        GLOBAL_WORKSPACE = '/var/jenkins_home_host_mount'

        // Flutter build container
        FLUTTER_IMAGE       = 'flutter_rust_env'
        FLUTTER_PROJECT_DIR = '/sudoku_app'

        // Repository paths
        SCRIPTS_DIR = 'scripts'

        // Script paths
        CLEAN_GRADLE_SCRIPT     = "${SCRIPTS_DIR}/clean_gradle_cache.sh"
        CLEAN_FLUTTER_SCRIPT    = "${SCRIPTS_DIR}/clean_flutter.sh"
        BUILD_ALL_SCRIPT        = "${SCRIPTS_DIR}/build_all.sh"
        BUILD_DEBUG_ARGS        = 'debug'
        BUILD_RELEASE_ARGS      = 'release'
        INTEGRATION_TEST_SCRIPT = "${SCRIPTS_DIR}/run_integration_test.sh"
        PLANTUML_SCRIPT         = "${SCRIPTS_DIR}/generate_PlantUML_PDF.ps1"
    }

    stages {

        stage('Prepare Workspace') {
            steps {
                script {
                    ws("${GLOBAL_WORKSPACE}") {
                        // Run shell commands and explicitly check success
                        def result = sh(script: '''
                            mkdir -p "$WORKSPACE" || exit 1
                            chown -R $(id -u):$(id -g) "$WORKSPACE" || exit 1
                        ''', returnStatus: true)

                        if (result == 0) {
                            echo "✅ Workspace prepared successfully"
                        } else {
                            error("❌ Failed to prepare workspace. Check permissions on ${GLOBAL_WORKSPACE}")
                        }
                    }
                }
            }
        }


        stage('Checkout') {
            steps {
                script {
                    ws("${GLOBAL_WORKSPACE}") {
                        checkout scm
                    }
                }
            }
        }

        stage('Validate Repo Structure') {
            steps {
                script {
                    ws("${GLOBAL_WORKSPACE}") {
                        sh '''
                            test -d scripts || { echo "❌ scripts/ directory missing after checkout"; exit 1; }
                        '''
                    }
                }
            }
        }

        stage('Workspace Validation') {
            steps {
                script {
                    ws("${GLOBAL_WORKSPACE}") {
                        sh '''
                            set -e
                            echo "Workspace: $WORKSPACE"
                            echo "Listing workspace contents (long format with numeric UID/GID):"
                            ls -ln "$WORKSPACE"

                            test -w "$WORKSPACE" || { echo "❌ Workspace not writable"; exit 1; }
                            test -d scripts || { echo "❌ scripts directory missing"; exit 1; }

                            echo "✅ Workspace validation passed"
                        '''
                    }
                }
            }
        }

        stage('Docker Mount Validation') {
            steps {
                script {
                    ws("${GLOBAL_WORKSPACE}") {
                        sh '''
                            set -e
                            echo "=============================="
                            echo "🔍 Docker Mount Validation"
                            echo "=============================="

                            echo "Host workspace path:"
                            echo "$WORKSPACE"
                            echo "Listing host workspace contents (long format with numeric UID/GID):"
                            ls -ln "$WORKSPACE"

                            echo "UID/GID on host:"
                            stat -c '%U %G %a' "$WORKSPACE"

                            echo "Container check..."
                            docker run --rm \
                              --user $(id -u):$(id -g) \
                              -v "$WORKSPACE:$FLUTTER_PROJECT_DIR" \
                              -w "$FLUTTER_PROJECT_DIR" \
                              "$FLUTTER_IMAGE" \
                              bash -c "
                                set -e
                                echo 'Container UID/GID:'
                                id
                                echo 'Listing mounted directory inside container:'
                                ls -la
                                ls -ln
                                if [ ! -d scripts ]; then
                                  echo '❌ scripts/ directory missing inside container'
                                  echo 'Hint: Check host folder $WORKSPACE/scripts exists and is readable by UID $(id -u)'
                                  exit 1
                                fi
                                echo 'Testing write permission inside container...'
                                touch mount_test && rm mount_test || {
                                  echo '❌ Cannot write to mounted directory'
                                  echo 'Hint: Adjust host folder permissions: sudo chown -R $(id -u):$(id -g) $WORKSPACE'
                                  exit 1
                                }
                                echo '✅ Container mount test passed'
                              "
                        '''
                    }
                }
            }
        }

        stage('Clean Environment') {
            steps {
                script {
                    ws("${GLOBAL_WORKSPACE}") {
                        sh '''
                            docker run --rm \
                              --user $(id -u):$(id -g) \
                              -v "$WORKSPACE:$FLUTTER_PROJECT_DIR" \
                              -w "$FLUTTER_PROJECT_DIR" \
                              "$FLUTTER_IMAGE" \
                              bash -c "
                                set -e
                                ${CLEAN_GRADLE_SCRIPT}
                                ${CLEAN_FLUTTER_SCRIPT}
                              "
                        '''
                    }
                }
            }
        }

        stage('Build') {
            parallel {
                stage('Debug') {
                    steps {
                        script {
                            ws("${GLOBAL_WORKSPACE}") {
                                sh '''
                                    docker run --rm \
                                      --user $(id -u):$(id -g) \
                                      -v "$WORKSPACE:$FLUTTER_PROJECT_DIR" \
                                      -w "$FLUTTER_PROJECT_DIR" \
                                      "$FLUTTER_IMAGE" \
                                      bash -c "${BUILD_ALL_SCRIPT} ${BUILD_DEBUG_ARGS}"
                                '''
                            }
                        }
                    }
                }

                stage('Release') {
                    steps {
                        script {
                            ws("${GLOBAL_WORKSPACE}") {
                                sh '''
                                    docker run --rm \
                                      --user $(id -u):$(id -g) \
                                      -v "$WORKSPACE:$FLUTTER_PROJECT_DIR" \
                                      -w "$FLUTTER_PROJECT_DIR" \
                                      "$FLUTTER_IMAGE" \
                                      bash -c "${BUILD_ALL_SCRIPT} ${BUILD_RELEASE_ARGS}"
                                '''
                            }
                        }
                    }
                }
            }
        }

        stage('Run Integration Tests') {
            steps {
                script {
                    ws("${GLOBAL_WORKSPACE}") {
                        sh '''
                            docker run --rm \
                              --user $(id -u):$(id -g) \
                              -v "$WORKSPACE:$FLUTTER_PROJECT_DIR" \
                              -w "$FLUTTER_PROJECT_DIR" \
                              "$FLUTTER_IMAGE" \
                              bash -c "${INTEGRATION_TEST_SCRIPT}"
                        '''
                    }
                }
            }
        }

        stage('Generate Diagrams & PDF') {
            steps {
                script {
                    ws("${GLOBAL_WORKSPACE}") {
                        sh "pwsh ${PLANTUML_SCRIPT}"
                    }
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                script {
                    ws("${GLOBAL_WORKSPACE}") {
                        sh '''
                            mkdir -p build_outputs
                            cp android/sudoku_app/build/outputs/flutter-apk/*.apk build_outputs/ || true
                            cp android/sudoku_app/build/outputs/bundle/release/*.aab build_outputs/ || true
                        '''
                        archiveArtifacts artifacts: 'build_outputs/**', fingerprint: true
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished: ${currentBuild.currentResult}"
        }
        failure {
            echo "❌ Build failed — check logs above"
        }
        success {
            echo "✅ Build succeeded"
        }
    }
}
