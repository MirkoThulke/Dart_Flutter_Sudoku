pipeline {

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


    agent any

    options { skipDefaultCheckout true }

    environment {
        FLUTTER_IMAGE = 'flutter_rust_env'
        PROJECT_DIR   = '/sudoku_app'

        CLEAN_GRADLE_SCRIPT  = 'scripts/clean_gradle_cache.sh'
        CLEAN_FLUTTER_SCRIPT = 'scripts/clean_flutter.sh'
        BUILD_ALL_SCRIPT     = 'scripts/build_all.sh'
        BUILD_ALL_DEBUG_ARGS = 'debug'
        BUILD_ALL_RELEASE_ARGS = 'release'
        INTEGRATION_TEST_SCRIPT = 'scripts/run_integration_test.sh'
        GENERATE_PLANTUML_PDF_SCRIPT = 'scripts/generate_PlantUML_PDF.ps1'
    }

    stages {

        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Debug Mount') {

            steps {
                    sh '''
                        set -e

                        echo "=============================="
                        echo "🔍 DEBUG MOUNT CHECK"
                        echo "=============================="

                        echo "Jenkins WORKSPACE (host path):"
                        echo "$WORKSPACE"
                        test -d "$WORKSPACE" || {
                          echo "❌ WORKSPACE does not exist on Jenkins host"
                          exit 1
                        }

                        echo ""
                        echo "Running container mount inspection..."

                        docker run --rm \
                          -v "$WORKSPACE:$PROJECT_DIR" \
                          -w "$PROJECT_DIR" \
                          "$FLUTTER_IMAGE" \
                          bash -c '
                            set -e

                            echo "📁 Container working directory:"
                            pwd

                            echo ""
                            echo "📦 Container directory listing:"
                            ls -la

                            echo ""
                            echo "📜 Checking scripts directory..."
                            if [ ! -d scripts ]; then
                              echo "❌ ERROR: scripts/ directory NOT FOUND inside container"
                              exit 1
                            fi

                            echo "✅ scripts/ directory exists"

                            echo ""
                            echo "📜 scripts/ contents:"
                            ls -la scripts

                            echo ""
                            echo "🔐 Executable flags:"
                            ls -l scripts/*.sh || {
                              echo "❌ ERROR: No executable scripts found"
                              exit 1
                            }

                            echo ""
                            echo "✅ DEBUG MOUNT CHECK PASSED"
                          '
                    '''
            }
        }

        stage('Clean Environment') {
            steps {
                sh """
                    docker run --rm -v "${WORKSPACE}:${PROJECT_DIR}" -w ${PROJECT_DIR} $FLUTTER_IMAGE \
                        bash -c "$CLEAN_GRADLE_SCRIPT && $CLEAN_FLUTTER_SCRIPT"
                """
            }
        }

        stage('Build') {
            parallel {
                stage('Debug') {
                    steps {
                        sh """
                            docker run --rm -v "${WORKSPACE}:${PROJECT_DIR}" -w ${PROJECT_DIR} $FLUTTER_IMAGE \
                                bash $BUILD_ALL_SCRIPT $BUILD_ALL_DEBUG_ARGS
                        """
                    }
                }
                stage('Release') {
                    steps {
                        sh """
                            docker run --rm -v "${WORKSPACE}:${PROJECT_DIR}" -w ${PROJECT_DIR} $FLUTTER_IMAGE \
                                bash $BUILD_ALL_SCRIPT $BUILD_ALL_RELEASE_ARGS
                        """
                    }
                }
            }
        }

        stage('Run Integration Tests') {
            steps {
                sh """
                    docker run --rm -v "${WORKSPACE}:${PROJECT_DIR}" -w ${PROJECT_DIR} $FLUTTER_IMAGE \
                        bash $INTEGRATION_TEST_SCRIPT
                """
            }
        }

        stage('Generate Diagrams & PDF') {
            steps {
                sh "pwsh ${GENERATE_PLANTUML_PDF_SCRIPT}"
            }
        }

        stage('Archive Artifacts') {
            steps {
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
