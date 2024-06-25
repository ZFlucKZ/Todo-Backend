pipeline{
    agent any

    environment {
        registry = "darkza5050/todo-backend"
        registryCredential = 'dockerhub'
    }

    stages{
        stage('Unit test'){
            steps{
                sh 'go test -v ./... -coverprofile=coverage.out'
            }
        }

        stage('Integration test'){
            steps{
                sh 'make test-it-docker'
            }
        }

        stage('SonarQube Scan'){
            steps{
                withSonarQubeEnv('sonar-todo'){
                    sh '''
                        sonar-scanner \
                        -Dsonar.projectKey=${PROJECT_NAME} \
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
                    dockerImage = docker.build registry + ":V$BUILD_NUMBER"
                }
            }
        }

        stage('Push Docker Image'){
            steps{
                script{
                    docker.withRegistry('', registryCredential){
                        dockerImage.push('V$BUILD_NUMBER')
                        dockerImage.push('latest')
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
