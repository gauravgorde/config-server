pipeline {
    agent any
    environment {
        AWS_REGION = 'ap-south-1'
        ECR_REPO_NAME = 'springapp'
        AWS_ACCOUNT_ID = '339712936703' 
        registry = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
        IMAGE_NAME = '339712936703.dkr.ecr.ap-south-1.amazonaws.com/springapp:latest'
        DOCKER_HOST = "ssh://ubuntu@ec2-3-110-225-30.ap-south-1.compute.amazonaws.com" // Docker instance SSH details
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
                }
            }
        }
        stage('Deploy to Docker Instance') {
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
                    
                    // Copy the updated docker-compose.yml to the Docker instance
                    sh "scp -i /path/to/docker.pem ${composeFilePath} ${DOCKER_HOST}:/path/to/deploy/docker-compose.yml" // Update the path as needed
                    
                    // Pull the latest Docker image and deploy using Docker Compose on the Docker instance
                    sh """
                        ssh -i /path/to/docker.pem ${DOCKER_HOST} << EOF
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${registry}
                            docker pull ${IMAGE_NAME}
                            cd /path/to/deploy
                            docker-compose down
                            docker-compose up -d
                        EOF
                    """
                }
            }
        }
    }
}
