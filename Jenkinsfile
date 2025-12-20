

pipeline {
    agent any

    environment {
        FLUTTER_IMAGE = 'flutter_rust_env'
        PROJECT_DIR = '/app'

        // Define script paths here
        CLEAN_GRADLE_SCRIPT             = './scripts/clean_gradle_cache.sh'
        CLEAN_FLUTTER_SCRIPT            = './scripts/clean_flutter.sh'

        BUILD_ALL_SCRIPT                = './scripts/build_all.sh'
        BUILD_ALL_DEBUG_ARGS            = 'debug'
        BUILD_ALL_RELEASE_ARGS          = 'release'

        INTEGRATION_TEST_SCRIPT         = './scripts/run_integration_test.sh'
        GENERATE_PLANTUML_PDF_SCRIPT    = './scripts/generate_PlantUML_PDF.ps1'
    }

    stages {

        stage('Make Scripts Executable') {
            steps {
                    sh "chmod +x \$CLEAN_GRADLE_SCRIPT"
                    sh "chmod +x \$CLEAN_FLUTTER_SCRIPT"
                    sh "chmod +x \$BUILD_ALL_SCRIPT"
                    sh "chmod +x \$INTEGRATION_TEST_SCRIPT"
                    sh "chmod +x \$GENERATE_PLANTUML_PDF_SCRIPT"
            }
        }

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
                        env.CLEAN_GRADLE_SCRIPT,
                        env.CLEAN_FLUTTER_SCRIPT
                    ]
                    for (cmd in commands) {
                        sh """
                        docker run --rm \
                        -v \$WORKSPACE:$PROJECT_DIR \
                        -w $PROJECT_DIR \
                        $FLUTTER_IMAGE \
                        bash -lc "${cmd}"
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
                            bash -lc "${env.BUILD_ALL_SCRIPT} ${env.BUILD_ALL_DEBUG_ARGS}"
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
                            bash -lc "${env.BUILD_ALL_SCRIPT} ${env.BUILD_ALL_RELEASE_ARGS}"
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
