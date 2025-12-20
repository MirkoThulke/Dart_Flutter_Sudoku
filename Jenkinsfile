pipeline {
    agent any

    environment {
        FLUTTER_IMAGE = 'flutter_rust_env'
        PROJECT_DIR = '/app'
    }

    stages {

        // Verify Docker from inside Jenkins (mandatory gate)
        stage('Verify Docker Host') {

            steps {
                sh './scripts/install_docker_host.sh'
            }
            
            steps {
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
                        './scripts/clean_gradle_cache.sh',
                        './scripts/clean_flutter.sh'
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
                            bash -lc './scripts/build_all.sh debug'
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
                            bash -lc './scripts/build_all.sh release'
                        """
                    }
                }
            }
        }

        stage('Generate Diagrams & PDF') {
            steps {
                sh 'pwsh ./scripts/generate_PlantUML_PDF.ps1'
            }
        }

        stage('Run Integration Tests') {
            steps {
                sh """
                docker run --rm \
                    -v \$WORKSPACE:$PROJECT_DIR \
                    -w $PROJECT_DIR \
                    $FLUTTER_IMAGE \
                    bash -lc './scripts/run_integration_test.sh'
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
