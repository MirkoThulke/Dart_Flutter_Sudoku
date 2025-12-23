//  ------------------------------------------------------------
//  CI Workflow to build and push image to Docker Hub:
// 
//  GitHub → Jenkins (container) → docker run → flutter_rust_env (container)
//  
//  Run Jenkins in browser on Host :
//    http://localhost:8080
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
//         │   └── /var/jenkins_home/workspace/Flutter_Docker_Pipeline
//         │       └── <-- SOURCE CODE LIVES HERE
//         │
//         └── Flutter build container
//             └── /sudoku_app  (bind-mounted from Jenkins workspace)

// Run Jenkins container with:
//   docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v /home/mirko/jenkins-home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins:latest
//   docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v /home/mirko/jenkins-home:/var/jenkins_home -v /home/mirko/jenkins-workspace:/workspace -v /var/run/docker.sock:/var/run/docker.sock jenkins:latest
//   sudo chown -R 1000:1000 /home/mirko/jenkins-home
//   sudo mkdir -p /home/mirko/jenkins-workspace
//   sudo chown -R 1000:1000 /home/mirko/jenkins-workspace

// Enter the jenkins container shell:
//   docker exec -it jenkins bash

//  ------------------------------------------------------------
// Print the initial admin password
//   cat /var/jenkins_home/secrets/initialAdminPassword
//   exit
// ------------------------------------------------------------

pipeline {

    agent any

    options { skipDefaultCheckout true }

    environment {
        HOST_WORKSPACE = '/home/mirko/jenkins-workspace/Flutter_Docker_Pipeline'


       FLUTTER_IMAGE = 'flutter_rust_env'
       PROJECT_DIR   = '/sudoku_app'

       SCRIPTS_DIR = 'scripts'

       CLEAN_GRADLE_SCRIPT     = "${SCRIPTS_DIR}/clean_gradle_cache.sh"
       CLEAN_FLUTTER_SCRIPT    = "${SCRIPTS_DIR}/clean_flutter.sh"

       BUILD_ALL_SCRIPT        = "${SCRIPTS_DIR}/build_all.sh"
       BUILD_DEBUG_ARGS        = 'debug'
       BUILD_RELEASE_ARGS      = 'release'

       INTEGRATION_TEST_SCRIPT = "${SCRIPTS_DIR}/run_integration_test.sh"
       PLANTUML_SCRIPT         = "${SCRIPTS_DIR}/generate_PlantUML_PDF.ps1"
    }

    stages {

        stage('Checkout') {
            steps {
                ws("${HOST_WORKSPACE}") {
                    checkout scm
                }
            }
        }

        stage('Debug Mount') {
            steps {
                ws("${HOST_WORKSPACE}") {
                    sh '''
                        set -e

                        echo "=============================="
                        echo "🔍 DEBUG MOUNT CHECK"
                        echo "=============================="

                        echo "Jenkins workspace:"
                        pwd
                        ls -la

                        test -d scripts || {
                          echo "❌ scripts/ directory missing in Jenkins workspace"
                          exit 1
                        }

                        docker run --rm \
                          -v "$HOST_WORKSPACE:/sudoku_app" \
                          -w /sudoku_app \
                          "$FLUTTER_IMAGE" \
                          bash -c '
                            set -e
                            echo "📁 Container PWD:"
                            pwd
                            echo "📦 Listing:"
                            ls -la
                            echo "📜 scripts/:"
                            ls -la scripts
                          '

                        echo "✅ DEBUG MOUNT CHECK PASSED"
                    '''
                }
            }
        }

        stage('Clean Environment') {
            steps {
                ws("${HOST_WORKSPACE}") {
                    sh '''
                        docker run --rm \
                          -v "$HOST_WORKSPACE:$PROJECT_DIR" \
                          -w "$PROJECT_DIR" \
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
                        ws("${HOST_WORKSPACE}") {
                            sh '''
                                docker run --rm \
                                  -v "$HOST_WORKSPACE:$PROJECT_DIR" \
                                  -w "$PROJECT_DIR" \
                                  "$FLUTTER_IMAGE" \
                                  bash -c "${BUILD_ALL_SCRIPT} ${BUILD_DEBUG_ARGS}"
                            '''
                        }
                    }
                }

                stage('Release') {
                    steps {
                        ws("${HOST_WORKSPACE}") {
                            sh '''
                                docker run --rm \
                                  -v "$HOST_WORKSPACE:$PROJECT_DIR" \
                                  -w "$PROJECT_DIR" \
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
                ws("${HOST_WORKSPACE}") {
                    sh '''
                        docker run --rm \
                          -v "$HOST_WORKSPACE:$PROJECT_DIR" \
                          -w "$PROJECT_DIR" \
                          "$FLUTTER_IMAGE" \
                          bash -c "${INTEGRATION_TEST_SCRIPT}"
                    '''
                }
            }
        }

        stage('Generate Diagrams & PDF') {
            steps {
                ws("${HOST_WORKSPACE}") {
                    sh "pwsh ${GENERATE_PLANTUML_PDF_SCRIPT}"
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                ws("${HOST_WORKSPACE}") {
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

