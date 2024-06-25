pipeline{
    agent any

    tools { 
        go 'Go1.21.9'
        dockerTool 'docker-latest'
    }

    environment {
        registry = "darkza5050/todo-backend"
        registryCredential = 'dockerhub'
    }

    stages{
        stage("Set up make, docker-compose"){
            steps{
                sh '''
                    if ! dpkg -l | grep -q "^ii  make "; then
                        apt-get update
                        apt-get install -y make
                    else
                        echo "make is already installed."
                    fi
                    if ! dpkg -l | grep -q "^ii  docker-compose "; then
                        apt-get update
                        apt-get install -y docker-compose
                    else
                        echo "docker-compose is already installed."
                    fi
                '''
            }
        }

        stage('Unit test'){
            steps{
                script {
                    sh 'go version'
                    sh 'go test -v ./... -coverprofile=coverage.out'
                }
            }
        }

        stage('Integration test'){
            steps{
                // sh 'docker-compose -f docker-compose.it.test.yaml down && \
	            //     docker-compose -f docker-compose.it.test.yaml up --build --force-recreate --abort-on-container-exit --exit-code-from it_tests'
                echo 'Integration test is disabled for now'
            }
        }

        stage('SonarQube Scan'){
            environment {
                scannerHome = tool 'sonar4.7'
            }

            steps{
                withSonarQubeEnv('sonar-todo'){
                    sh '''
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=todo-backend \
                        -Dsonar.sources=. \
                        -Dsonar.tests=. \
                        -Dsonar.test.inclusions=**/*_test.go \
                        -Dsonar.go.coverage.reportPaths=coverage.out \
                        -Dsonar.language=go
                    '''
                }

                timeout(time: 5, unit: 'MINUTES'){
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Image'){
            steps{
                script{
                    dockerImage = docker.build(registry + ":V$BUILD_NUMBER")
                }
            }
        }

        stage('Push Docker Image'){
            steps{
                script{
                    docker.withRegistry('', registryCredential){
                        dockerImage.push(registry + ":V$BUILD_NUMBER")
                    }
                }
            }
        }

        stage('Remove Unused docker image') {
          steps{
            sh "docker rmi $registry:V$BUILD_NUMBER"
          }
        }
    }
}  
