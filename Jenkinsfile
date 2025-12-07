pipeline {
    agent any

    environment {
        FLUTTER_IMAGE = 'flutter_rust_env'
        PROJECT_DIR = '/app'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Clean environment') {
            steps {
                sh """
                docker run --rm \
                    -v \$WORKSPACE:$PROJECT_DIR \
                    -w $PROJECT_DIR \
                    $FLUTTER_IMAGE \
                    bash -lc './scripts/clean_flutter.sh'
                """
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

        stage('Archive Artifacts') {
            steps {
                sh "mkdir -p build_outputs"

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
