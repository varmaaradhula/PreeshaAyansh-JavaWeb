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
                  fi

                   # Set Git user details
                  git config user.email "rkvarmaa@gmail.com"
                  git config user.name "Varma Aradhula"

                # Extract the previous build number (Assumes format: image: myrepo/myapp:<number>)
                OLD_BUILD_NUMBER=$(grep -oP 'image: varmaaradhula/preeaya:\\K[0-9]+'PreeshaAyansh_deployments/MyApp.yml)

                   # Update deployment file with new image tag
                    BUILD_NUMBER=${BUILD_NUMBER}
                   echo "Replacing old build number ($OLD_BUILD_NUMBER) with new build number ($BUILD_NUMBER)"
                    sed -i'' -e "s/$OLD_BUILD_NUMBER/${BUILD_NUMBER}/g" PreeshaAyansh_deployments/MyApp.yml

                    # Commit and push changes
                    git add PreeshaAyansh_deployments/MyApp.yml
                    git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                    git push origin master
                '''
            }
        }
    }
  }
}
