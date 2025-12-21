pipeline {

// Jenkins container
//   └── /var/jenkins_home/workspace/Flutter_Docker_Pipeline
//         └── scripts/*.sh
//               │
//               └── mounted as
//                     ▼
// Flutter container
//   └── /app/scripts/*.sh

    agent any

    environment {
        FLUTTER_IMAGE = 'flutter_rust_env'
        PROJECT_DIR   = '/app'

        // Script paths INSIDE the container
        CLEAN_GRADLE_SCRIPT          = 'scripts/clean_gradle_cache.sh'
        CLEAN_FLUTTER_SCRIPT         = 'scripts/clean_flutter.sh'

        BUILD_ALL_SCRIPT             = 'scripts/build_all.sh'
        BUILD_ALL_DEBUG_ARGS         = 'debug'
        BUILD_ALL_RELEASE_ARGS       = 'release'

        INTEGRATION_TEST_SCRIPT      = 'scripts/run_integration_test.sh'
        GENERATE_PLANTUML_PDF_SCRIPT = 'scripts/generate_PlantUML_PDF.ps1'
    }

    stages {


        // Verify Docker from inside Jenkins (mandatory gate)
        stage('Docker Socket Check') {
            steps {
                sh '''
                    echo "🔍 Checking Docker socket"
                    test -S /var/run/docker.sock || {
                      echo "❌ Docker socket not mounted"
                      exit 1
                    }
                    echo "✅ Docker socket present"
                '''
            }
        }


        // Jenkins log where it is running
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
                    echo "Workspace:"
                    pwd
                    ls -la
                    echo "Scripts:"
                    ls -la scripts
                '''
            }
        }

        stage('Clean environment') {
            steps {
                script {
                    def commands = [
                        env.CLEAN_GRADLE_SCRIPT,
                        env.CLEAN_FLUTTER_SCRIPT
                    ]

                    for (cmd in commands) {
                        sh """
                            docker run --rm \
                              -v "\$WORKSPACE:$PROJECT_DIR" \
                              -w $PROJECT_DIR \
                              $FLUTTER_IMAGE \
                              bash -lc "./${cmd}"
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
                              -v "\$WORKSPACE:$PROJECT_DIR" \
                              -w $PROJECT_DIR \
                              $FLUTTER_IMAGE \
                              bash -lc "./${BUILD_ALL_SCRIPT} ${BUILD_ALL_DEBUG_ARGS}"
                        """
                    }
                }
                stage('Release') {
                    steps {
                        sh """
                            docker run --rm \
                              -v "\$WORKSPACE:$PROJECT_DIR" \
                              -w $PROJECT_DIR \
                              $FLUTTER_IMAGE \
                              bash -lc "./${BUILD_ALL_SCRIPT} ${BUILD_ALL_RELEASE_ARGS}"
                        """
                    }
                }
            }
        }

        stage('Generate Diagrams & PDF') {
            steps {
                sh "pwsh ${GENERATE_PLANTUML_PDF_SCRIPT}"
            }
        }

        stage('Run Integration Tests') {
            steps {
                sh """
                    docker run --rm \
                      -v "\$WORKSPACE:$PROJECT_DIR" \
                      -w $PROJECT_DIR \
                      $FLUTTER_IMAGE \
                      bash -lc "./${INTEGRATION_TEST_SCRIPT}"
                """
            }
        }

        stage('Archive Artifacts') {
            steps {
                sh '''
                    mkdir -p build_outputs
                    cp android/app/build/outputs/flutter-apk/*.apk build_outputs/ || true
                    cp android/app/build/outputs/bundle/release/*.aab build_outputs/ || true
                '''

                archiveArtifacts artifacts: 'build_outputs/**', fingerprint: true
            }
        }
    }
}
