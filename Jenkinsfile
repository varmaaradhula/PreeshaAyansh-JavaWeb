pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps {
        sh 'echo passed'
        //git branch: 'main', url: 'https://github.com/varmaaradhula/PreeshaAyansh-JavaWeb.git'
      }
    }

 stage('Build and Test') {
      steps {
        sh 'ls -ltr'
        // build the project and create a JAR file
        sh ' mvn clean package'
      }
    }

  stage("CheckStyle reports"){
            steps{
                sh 'mvn checkstyle:checkstyle'
            }
        }

  stage ("SonarQube analysis"){
            steps {
                echo 'Starting SonarQube analysis...'
                withSonarQubeEnv('SonarServer') {
                    sh """ mvn sonar:sonar \
                          -Dsonar.projectKey=myPreeshaAyansh
                          """
                }
            }
        }

 stage('Build and Push Docker Image') {
    environment {
        DOCKER_IMAGE = "varmaaradhula/preeaya:${BUILD_NUMBER}"
        REGISTRY_CREDENTIALS = credentials('docker-hub-creds')  // Jenkins credentials ID for Docker Hub
    }
    steps {
        script {
            // Navigate to project directory and build the image
            sh """
                docker build -t ${DOCKER_IMAGE} .
            """
            
            // Log in to Docker Hub and push the image
            docker.withRegistry('https://index.docker.io/v1/', "docker-hub-creds") {
                sh "docker push ${DOCKER_IMAGE}"
            }
        }
    }
}
    stage('Update Deployment File') {
        environment {
            GIT_REPO_NAME = "PA-Deployments"
            GIT_USER_NAME = "varmaaradhula"
            GIT_BRANCH = "master"
        }
        steps {
            withCredentials([sshUserPrivateKey(credentialsId: 'gitsshKey', keyFileVariable: 'SSH_KEY')]) {
                sh '''
                    set -e  # Exit script on any error

                    # Start SSH agent and add private key
                    eval "$(ssh-agent -s)"
                    ssh-add $SSH_KEY

                    # Check if the repo already exists
                    if [ -d "${GIT_REPO_NAME}/.git" ]; then
                        echo "Repository exists. Pulling latest changes..."
                        cd ${GIT_REPO_NAME}
                        git reset --hard  # Reset any local changes
                        git checkout ${GIT_BRANCH}  # Ensure we're on the correct branch
                        git pull origin ${GIT_BRANCH}  # Pull latest changes
                    else
                        git clone git@github.com:${GIT_USER_NAME}/${GIT_REPO_NAME}.git
                        cd ${GIT_REPO_NAME}
                        git checkout ${GIT_BRANCH}
                    fi

                    # Set Git user details
                    git config user.email "rkvarmaa@gmail.com"
                    git config user.name "Varma Aradhula"

                    # Ensure BUILD_NUMBER is set
                    if [ -z "$BUILD_NUMBER" ]; then
                        echo "Error: BUILD_NUMBER is not set"
                        exit 1
                    fi

                    # Extract the previous build number
                    OLD_BUILD_NUMBER=$(grep -oP 'image: varmaaradhula/preeaya:\\K[0-9]+' PreeshaAyansh_deployments/MyApp.yaml || echo "")

                    if [ -z "$OLD_BUILD_NUMBER" ]; then
                        echo "Error: Could not extract previous build number"
                        exit 1
                    fi

                    # Update deployment file with new image tag
                    echo "Replacing old build number ($OLD_BUILD_NUMBER) with new build number ($BUILD_NUMBER)"
                    sed -i.bak -e "s/$OLD_BUILD_NUMBER/${BUILD_NUMBER}/g" PreeshaAyansh_deployments/MyApp.yaml
                    rm -f PreeshaAyansh_deployments/MyApp.yaml.bak  # Cleanup backup file

                    # Commit and push changes
                    git add PreeshaAyansh_deployments/MyApp.yaml
                    git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                    git push origin ${GIT_BRANCH}
                '''
            }
        }
    }
  }
}
