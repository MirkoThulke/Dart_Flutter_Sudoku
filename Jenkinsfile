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


    agent {
        docker {
            image 'jenkins/jenkins:lts'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
            reuseNode true
        }
    }

    options {
        skipDefaultCheckout true
    }

    environment {
        FLUTTER_IMAGE = 'flutter_rust_env'
        PROJECT_DIR   = '/sudoku_app'

        // Script paths INSIDE the Flutter container
        CLEAN_GRADLE_SCRIPT          = 'scripts/clean_gradle_cache.sh'
        CLEAN_FLUTTER_SCRIPT         = 'scripts/clean_flutter.sh'

        BUILD_ALL_SCRIPT             = 'scripts/build_all.sh'
        BUILD_ALL_DEBUG_ARGS         = 'debug'
        BUILD_ALL_RELEASE_ARGS       = 'release'

        INTEGRATION_TEST_SCRIPT      = 'scripts/run_integration_test.sh'
        GENERATE_PLANTUML_PDF_SCRIPT = 'scripts/generate_PlantUML_PDF.ps1'
    }

    stages {

        stage('Docker Socket Check') {
            steps {
                sh '''
                    echo "🔍 Checking Docker socket"
                    test -S /var/run/docker.sock || { echo "❌ Docker socket not mounted"; exit 1; }
                    echo "✅ Docker socket present"
                '''
            }
        }

        stage('CI Environment Info') {
            steps {
                sh '''
                    echo "🏗️ Jenkins Environment"
                    hostname
                    test -f /.dockerenv && echo "Running inside Docker"
                    ls -l /var/run/docker.sock
                '''
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Debug Workspace') {
            steps {
                sh '''
                    echo "Workspace: $WORKSPACE"
                    ls -la "$WORKSPACE"
                    echo "Scripts:"
                    ls -la "$WORKSPACE/scripts"
                '''
            }
        }

        stage('Clean environment') {
            steps {
                script {
                    def commands = [CLEAN_GRADLE_SCRIPT, CLEAN_FLUTTER_SCRIPT]

                    for (cmd in commands) {
                        sh """
                            docker run --rm \
                                -v "$WORKSPACE:$PROJECT_DIR" \
                                -w $PROJECT_DIR \
                                $FLUTTER_IMAGE \
                                bash $cmd
                        """
                    }
                }
            }
        }

        stage('Build Debug & Release') {
            parallel {
                stage('Debug') {
                    steps {
                        sh """
                            docker run --rm \
                                -v "$WORKSPACE:$PROJECT_DIR" \
                                -w $PROJECT_DIR \
                                $FLUTTER_IMAGE \
                                bash $BUILD_ALL_SCRIPT $BUILD_ALL_DEBUG_ARGS
                        """
                    }
                }
                stage('Release') {
                    steps {
                        sh """
                            docker run --rm \
                                -v "$WORKSPACE:$PROJECT_DIR" \
                                -w $PROJECT_DIR \
                                $FLUTTER_IMAGE \
                                bash $BUILD_ALL_SCRIPT $BUILD_ALL_RELEASE_ARGS
                        """
                    }
                }
            }
        }

        stage('Generate Diagrams & PDF') {
            steps {
                sh "pwsh $GENERATE_PLANTUML_PDF_SCRIPT"
            }
        }

        stage('Run Integration Tests') {
            steps {
                sh """
                    docker run --rm \
                        -v "$WORKSPACE:$PROJECT_DIR" \
                        -w $PROJECT_DIR \
                        $FLUTTER_IMAGE \
                        bash $INTEGRATION_TEST_SCRIPT
                """
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
