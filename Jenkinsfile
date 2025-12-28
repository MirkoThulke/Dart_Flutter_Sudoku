//  ------------------------------------------------------------
//  CI Workflow to build and push image to Docker Hub:
// 
//  GitHub → Jenkins (container) → docker run → flutter_rust_env (container)
//  
//  /var/jenkins_home   → Jenkins config
//  /workspace          → builds + @tmp
//  //  Jenkins pulls your app from GitHub into its workspace:
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
//   ├── /home/mirko/jenkins_home_host_mount_workspace  ← Jenkins data
//   ├── Docker daemon
//   │   └── /var/run/docker.sock
//   │
//   └── Jenkins container
//       ├── /var/jenkins_home
//       └── /workspace  ← mounted
//       └── Docker CLI → host Docker
//
// Build artefacts are stored in :
//    /var/jenkins_home/jobs/Flutter_Docker_Pipeline/builds/<build-id>/archive/
// ------------------------------------------------------------

// Jenkins container
//   └── /var/jenkins_home
//   └── /workspace/Flutter_Docker_Pipeline
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
//   -v /home/mirko/jenkins_home_host_mount:/var/jenkins_home
//   -v /home/mirko/jenkins_workspace_host_mount:/workspace
//   🚨 THIS IS THE MOST IMPORTANT LINE
//
//    docker mount command, https://docs.docker.com/engine/storage/bind-mounts/ : 
//       docker run -v <host-path>:<container-path>[:opts]
//       The $(pwd) sub-command expands to the current working directory on Linux
//
//   This is a bind mount:
//   Host (WSL2)	                                Container
//   /home/mirko/jenkins_home_host_mount	        /var/jenkins_home
//   /home/mirko/jenkins_workspace_host_mount	    /workspace

//   Comment : Jenkins is storing its workspaces under /var/jenkins_home by default 
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
//  -v …:/workspace	                                    Persist Jenkins build data
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
//
//  Prepare host directories for Jenkins home and workspace:
//  # Jenkins home
//  sudo mkdir -p /home/mirko/jenkins_home_host_mount
//  sudo chown -R 2000:2000 /home/mirko/jenkins_home_host_mount
//  sudo chmod -R 770 /home/mirko/jenkins_home_host_mount
//  

// Docker compose build via your compose.yaml file
//     docker compose up -d --build
//     docker compose down
//     docker compose logs -f
//     docker compose ps
//
//  Check ownership and permissions of the Jenkins workspace:
//   ls -ld /home/mirko/jenkins_home_host_mount
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
    agent none // We'll define agents per stage

    options {
        skipDefaultCheckout true
    }

    environment {
        // Flutter build container
        FLUTTER_IMAGE       = 'flutter_rust_env'

        // Host and container paths
        HOST_WORKSPACE      = '/home/mirko/jenkins_workspace_host_mount'
        CONTAINER_WORKSPACE = '/workspace/Flutter_Docker_Pipeline'

        FLUTTER_PROJECT_DIR = "${CONTAINER_WORKSPACE}" // inside container

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

        // Docker agent args template
        DOCKER_AGENT_ARGS_JENKINS       = "-u 2000:2000 -v ${HOST_WORKSPACE}:/workspace -w ${CONTAINER_WORKSPACE}"
        DOCKER_AGENT_ARGS_ROOT          = "-u 0:0 -v ${HOST_WORKSPACE}:/workspace -w ${CONTAINER_WORKSPACE}"
    }


    stages {


        stage('Checkout') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_JENKINS}"
                }
            }
            steps {
                checkout scm
                sh 'pwd'
                sh 'ls -la'
            }
        }


        stage('Validate Repo Structure') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    args "${DOCKER_AGENT_ARGS_JENKINS}"
                }
            }
            steps {
                script {
                    if (!fileExists("${SCRIPTS_DIR}")) {
                        error "❌ scripts directory not found"
                    } else {
                        echo "✅ scripts directory exists"
                    }
                }
            }
        }


        stage('Clean Environment') {
            agent {
                docker {
                    image "${FLUTTER_IMAGE}"
                    // Use root to ensure we can delete all cache files
                    args "${DOCKER_AGENT_ARGS_ROOT}"
                }
            }
            steps {
                sh '''
                    set -e
                    echo "🧹 Cleaning Gradle and Flutter caches"
                    ${CLEAN_GRADLE_SCRIPT}
                    ${CLEAN_FLUTTER_SCRIPT}
                '''
            }
        }

/*
        stage('Build') {
            parallel {
                stage('Debug') {
                    steps {
                        script {
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
*/
/*

                stage('Release') {
                    steps {
                        script {
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
*/
/*

        stage('Run Integration Tests') {
            steps {
                script {
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

*/
/*
        stage('Generate Diagrams & PDF') {
            steps {
                script {
                        sh "pwsh ${PLANTUML_SCRIPT}"
                    }
            }
        }
*/
/*
        stage('Archive Artifacts') {
            steps {
                sh '''
                    set -e

                    echo "📦 Collecting build artifacts..."

                    OUTPUT_DIR="build_outputs"
                    mkdir -p "$OUTPUT_DIR"

                    found=0

                    APK_DIR="android/sudoku_app/build/outputs/flutter-apk"
                    AAB_DIR="android/sudoku_app/build/outputs/bundle/release"

                    if [ -d "$APK_DIR" ]; then
                      for f in "$APK_DIR"/*.apk; do
                        [ -e "$f" ] || continue
                        cp "$f" "$OUTPUT_DIR/"
                        echo "✔ Collected APK: $(basename "$f")"
                        found=1
                      done
                    else
                      echo "⚠️ APK directory not found: $APK_DIR"
                    fi

                    if [ -d "$AAB_DIR" ]; then
                      for f in "$AAB_DIR"/*.aab; do
                        [ -e "$f" ] || continue
                        cp "$f" "$OUTPUT_DIR/"
                        echo "✔ Collected AAB: $(basename "$f")"
                        found=1
                      done
                    else
                      echo "⚠️ AAB directory not found: $AAB_DIR"
                    fi

                    if [ "$found" -eq 0 ]; then
                      echo "⚠️ No artifacts were produced by this build"
                    else
                      echo "✅ Artifact collection completed"
                    fi
                '''
                archiveArtifacts artifacts: 'build_outputs/**',
                                 fingerprint: true,
                                 allowEmptyArchive: true
            }
        }
*/
    }



    post {
        always {
            echo "Cleaning up workspace if necessary"
            cleanWs()
        }
        success {
            echo "✅ Build succeeded"
        }
        failure {
            echo "❌ Build failed"
        }
    }


}