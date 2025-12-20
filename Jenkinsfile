

pipeline {
    agent any

    environment {
        FLUTTER_IMAGE = 'flutter_rust_env'
        PROJECT_DIR = '/app'

        // Define script paths here
        INSTALL_DOCKER_HOST_SCRIPT      = './scripts/install_docker_host.sh'
        CLEAN_GRADLE_SCRIPT             = './scripts/clean_gradle_cache.sh'
        CLEAN_FLUTTER_SCRIPT            = './scripts/clean_flutter.sh'
        BUILD_ALL_DEBUG_SCRIPT          = './scripts/build_all.sh debug'
        BUILD_ALL_RELEASE_SCRIPT        = './scripts/build_all.sh release'
        INTEGRATION_TEST_SCRIPT         = './scripts/run_integration_test.sh'
        GENERATE_PLANTUML_PDF_SCRIPT    = './scripts/generate_PlantUML_PDF.ps1'
    }

    stages {

        stage('Make Scripts Executable') {
            steps {
                    sh "chmod +x \$INSTALL_DOCKER_HOST_SCRIPT"
                    sh "chmod +x \$CLEAN_GRADLE_SCRIPT"
                    sh "chmod +x \$CLEAN_FLUTTER_SCRIPT"
                    sh "chmod +x \$BUILD_ALL_DEBUG_SCRIPT"
                    sh "chmod +x \$BUILD_ALL_RELEASE_SCRIPT"
                    sh "chmod +x \$INTEGRATION_TEST_SCRIPT"
                    sh "chmod +x \$GENERATE_PLANTUML_PDF_SCRIPT"
            }
        }


        // Verify Docker from inside Jenkins (mandatory gate)
        stage('Verify Docker Host') {

            steps {

                sh '$INSTALL_DOCKER_HOST_SCRIPT'

                sh '''
                  echo "🔍 Verifying Docker host from Jenkins..."

                  docker version

                  SERVER_API=$(docker version --format '{{.Server.APIVersion}}')
                  SERVER_VERSION=$(docker version --format '{{.Server.Version}}')

                  REQUIRED_API=1.44

                  if [ "$(printf '%s\n' "$REQUIRED_API" "$SERVER_API" | sort -V | head -n1)" != "$REQUIRED_API" ]; then
                    echo "❌ Docker API too old: $SERVER_API"
                    exit 1
                  fi

                  echo "✅ Docker host verified"
                '''
                }
        }

        // Jenkins log where it is running
        stage('CI Environment Info') {
            steps {
                sh '''
                echo "🏗️ Jenkins Environment"
                echo "Hostname: $(hostname)"
                echo "Running in container:"
                test -f /.dockerenv && echo YES || echo NO
                echo "Docker socket:"
                ls -l /var/run/docker.sock
                '''
            }
        }   

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Clean environment') {
            steps {
                script {
                    def commands = [
                        '$CLEAN_GRADLE_SCRIPT',
                        '$CLEAN_FLUTTER_SCRIPT'
                    ]
                    for (cmd in commands) {
                        sh """
                        docker run --rm \
                            -v \$WORKSPACE:$PROJECT_DIR \
                            -w $PROJECT_DIR \
                            $FLUTTER_IMAGE \
                            bash -lc '$cmd'
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
                            -v \$WORKSPACE:$PROJECT_DIR \
                            -w $PROJECT_DIR \
                            $FLUTTER_IMAGE \
                            bash -lc '$BUILD_ALL_DEBUG_SCRIPT'
                        """
                    }
                }
                stage('Release') {
                    steps {
                        sh """
                        docker run --rm \
                            -v \$WORKSPACE:$PROJECT_DIR \
                            -w $PROJECT_DIR \
                            $FLUTTER_IMAGE \
                            bash -lc '$BUILD_ALL_RELEASE_SCRIPT'
                        """
                    }
                }
            }
        }

        stage('Generate Diagrams & PDF') {
            steps {
                sh "pwsh \$GENERATE_PLANTUML_PDF_SCRIPT"
            }
        }

        stage('Run Integration Tests') {
            steps {
                sh """
                docker run --rm \
                    -v \$WORKSPACE:$PROJECT_DIR \
                    -w $PROJECT_DIR \
                    $FLUTTER_IMAGE \
                    bash -lc '$INTEGRATION_TEST_SCRIPT'
                """
            }
        }

        stage('Archive Artifacts') {
            steps {
                sh 'mkdir -p build_outputs'

                sh """
                cp android/app/build/outputs/flutter-apk/app-release.apk build_outputs/ || true
                cp android/app/build/outputs/flutter-apk/app-debug.apk build_outputs/ || true
                cp android/app/build/outputs/bundle/release/app-release.aab build_outputs/ || true
                """

                archiveArtifacts artifacts: 'build_outputs/**', fingerprint: true
            }
        }
    }
}
