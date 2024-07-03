
pipeline {
    agent any
    environment {
        AWS_REGION = 'ap-south-1'
        ECR_REPO_NAME = 'springapp'
        AWS_ACCOUNT_ID = '339712936703' 
        registry = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
        IMAGE_NAME = '339712936703.dkr.ecr.ap-south-1.amazonaws.com/springapp:latest'
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/gauravgorde/configserver.git']])
            }
        }
        stage('Maven Build') {
            steps {
                sh 'mvn clean install'
            }
        }
        stage('Docker Build') {
            steps {
                script {
                    // Check AWS CLI version
                    sh 'aws --version'
                    
                    // Print a message to indicate the Docker build process
                    echo 'Building Docker Image...'
                    
                    // Build the Docker image
                    def dockerImage = docker.build("${registry}:latest")
                    
                    // Print Docker image name
                    echo "Docker image built Success"
                }
            }
        }
        stage('Docker Image') {
            steps {
                script {
                    // Login to AWS ECR
                    sh 'aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${registry}'
                    
                    // Tag the Docker image
                    sh "docker tag ${registry}:latest ${registry}:latest"
                    
                    // Push the Docker image to ECR
                    sh "docker push ${registry}:latest"
                    
                    // Stop and remove any existing container with the name `configServer`
                    sh 'docker ps -f name=configServer -q | xargs --no-run-if-empty docker container stop'
                    sh 'docker container ls -a -f name=configServer -q | xargs --no-run-if-empty docker container rm'
                }
            }
        }
        stage('Docker Run') {
            steps {
                script {
                    // Run the Docker container
                    sh "docker run -d -p 8000:8000 --rm --name configServer ${registry}:latest"
                }
            }
        }
        stage('Pull Docker Image'){
             steps {
                script {
                    sh """
                        # Login to Amazon ECR
                        aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${registry}
                        
                        # Pull the latest Docker image
                        docker pull ${IMAGE_NAME}
                    """
                }
            }
        }
         stage('Docker Deploy') {
            steps {
                script {
                    // Path to the docker-compose.yml file in the repository
                    def composeFilePath = "${env.WORKSPACE}/docker-compose.yml"
                    
                    // Verify the docker-compose.yml file exists
                    
                        echo "docker-compose.yml found at ${composeFilePath}"
                        
                        // Update the image in the docker-compose.yml file
                        
                        sh """
                            sed -i 's|image:.*|image: ${IMAGE_NAME}|g' ${composeFilePath}
                        """
                        
                        // Deploy using Docker Compose
                        sh "docker-compose -f ${composeFilePath} up -d"
                    
                }
            }
        }
    }
}
