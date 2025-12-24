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
//   ├── /home/mirko/jenkins_home_host_mount  ← Jenkins data
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
//   -v /home/mirko/jenkins_home_wsl2_host_mount:/var/jenkins_home
//   🚨 THIS IS THE MOST IMPORTANT LINE
//
//    docker mount command, https://docs.docker.com/engine/storage/bind-mounts/ : 
//       docker run -v <host-path>:<container-path>[:opts]
//       The $(pwd) sub-command expands to the current working directory on Linux
//
//   This is a bind mount:
//   Host (WSL2)	                                Container
//   /home/mirko/jenkins_home_host_mount	    /var/jenkins_home
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
//  --name jenkins	                                    Name the container
//  -p 8080:8080	                                    Jenkins web UI
//  -p 50000:50000	                                    Jenkins agents
//  -v …:/var/jenkins_home	                            Persist Jenkins data
//  -v /var/run/docker.sock:/var/run/docker.sock	    Let Jenkins control Docker
//   jenkins:latest	                                    Jenkins image
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
//
//   sudo rm -rf /home/mirko/jenkins_home_host_mount
//   sudo mkdir -p /home/mirko/jenkins_home_host_mount
//   sudo mkdir -p /home/mirko/jenkins_home_host_mount/workspace/Flutter_Docker_Pipeline
//   sudo chown -R 1000:1000 /home/mirko/jenkins_home_host_mount
//   sudo chmod -R 755 /home/mirko/jenkins_home_host_mount
//   
//   docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v /home/mirko/jenkins_home_host_mount:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins:latest:lts
//   
//  ------------------------------------------------------------

//  ------------------------------------------------------------
// RUN THE JENINS CONTAINER !! STEP 2/4
//  ------------------------------------------------------------
//   Enter the jenkins container shell:
//     docker exec -it jenkins bash
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

    options { skipDefaultCheckout true }

    environment {

        // Jenkins container paths :
        JENKINS_HOME                = '/var/jenkins_home'
        JENKINS_CUSTOM_WORKSPACE    = '/var/jenkins_home/workspace/Flutter_Docker_Pipeline'
        JENKINS_SCRIPTS_DIR         = 'scripts'

        // Flutter build container paths :
        FLUTTER_IMAGE       = 'flutter_rust_env'
        FLUTTER_PROJECT_DIR = '/sudoku_app'

        // Mapped script paths ( scripts from GitHub repo ):
        CLEAN_GRADLE_SCRIPT     = "${JENKINS_SCRIPTS_DIR}/clean_gradle_cache.sh"
        CLEAN_FLUTTER_SCRIPT    = "${JENKINS_SCRIPTS_DIR}/clean_flutter.sh"

        BUILD_ALL_SCRIPT        = "${JENKINS_SCRIPTS_DIR}/build_all.sh"
        BUILD_DEBUG_ARGS        = 'debug'
        BUILD_RELEASE_ARGS      = 'release'

        INTEGRATION_TEST_SCRIPT = "${JENKINS_SCRIPTS_DIR}/run_integration_test.sh"
        PLANTUML_SCRIPT         = "${JENKINS_SCRIPTS_DIR}/generate_PlantUML_PDF.ps1"
    }

    stages {


        stage('Workspace Permissions Check') {
            steps {
                sh '''
                    set -e
                    test -w "$JENKINS_CUSTOM_WORKSPACE" || { echo "❌ Workspace not writable"; exit 1; }
                    test -d "$JENKINS_CUSTOM_WORKSPACE/scripts" || { echo "❌ scripts missing"; exit 1; }
                '''
            }
        }

        stage('Debug Mount') {
            steps {
                ws("${JENKINS_CUSTOM_WORKSPACE}") {
                    sh '''
                        set -e

                        echo "=============================="
                        echo "🔍 DEBUG MOUNT CHECK"
                        echo "=============================="

                        echo "Jenkins workspace:"
                        pwd
                        ls -la

                        # Check workspace write permission
                        test -w . || { echo "❌ Workspace not writable by Jenkins user"; exit 1; }

                        # Check scripts directory
                        test -d scripts || { echo "❌ scripts/ directory missing"; exit 1; }

                        # Optional: check write from Docker container
                        docker run --rm \
                          --user $(id -u):$(id -g) \
                          -v "$PWD:$FLUTTER_PROJECT_DIR" \
                          -w "$FLUTTER_PROJECT_DIR" \
                          "$FLUTTER_IMAGE" \
                          bash -c "touch docker_mount_test && rm docker_mount_test"

                        echo "✅ DEBUG MOUNT CHECK PASSED"
                    '''
                }
            }
        }

        stage('Checkout') {
            steps {
                ws("${JENKINS_CUSTOM_WORKSPACE}") {
                    checkout scm
                }
            }
        }

        stage('Clean Environment') {
            steps {
                ws("${JENKINS_CUSTOM_WORKSPACE}") {
                    sh '''
                        docker run --rm \
                          --user $(id -u):$(id -g) \
                          -v "$PWD:$FLUTTER_PROJECT_DIR" \
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


        stage('Build') {
            parallel {
            
                stage('Debug') {
                    steps {
                        ws("${JENKINS_CUSTOM_WORKSPACE}") {
                            sh '''
                                docker run --rm \
                                  --user $(id -u):$(id -g) \
                                  -v "$PWD:$FLUTTER_PROJECT_DIR" \
                                  -w "$FLUTTER_PROJECT_DIR" \
                                  "$FLUTTER_IMAGE" \
                                  bash -c "${BUILD_ALL_SCRIPT} ${BUILD_DEBUG_ARGS}"
                            '''
                        }
                    }
                }

                stage('Release') {
                    steps {
                        ws("${JENKINS_CUSTOM_WORKSPACE}") {
                            sh '''
                                docker run --rm \
                                  --user $(id -u):$(id -g) \
                                  -v "$PWD:$FLUTTER_PROJECT_DIR" \
                                  -w "$FLUTTER_PROJECT_DIR" \
                                  "$FLUTTER_IMAGE" \
                                  bash -c "${BUILD_ALL_SCRIPT} ${BUILD_RELEASE_ARGS}"
                            '''
                        }
                    }
                }
            }
        }

        stage('Run Integration Tests') {
            steps {
                ws("${JENKINS_CUSTOM_WORKSPACE}") {
                    sh '''
                        docker run --rm \
                          --user $(id -u):$(id -g) \
                          -v "$PWD:$FLUTTER_PROJECT_DIR" \
                          -w "$FLUTTER_PROJECT_DIR" \
                          "$FLUTTER_IMAGE" \
                          bash -c "${INTEGRATION_TEST_SCRIPT}"
                    '''
                }
            }
        }

        stage('Generate Diagrams & PDF') {
            steps {
                ws("${JENKINS_CUSTOM_WORKSPACE}") {
                    sh "pwsh ${GENERATE_PLANTUML_PDF_SCRIPT}"
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                ws("${JENKINS_CUSTOM_WORKSPACE}") {
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

