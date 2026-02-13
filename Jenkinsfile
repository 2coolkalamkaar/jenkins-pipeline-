pipeline {
    agent any
    environment {
        SERVER_IP = credentials('prod-dash-server-dash-IP') 
        IMAGE_NAME = 'kalamkaar/flaskapp' 
        IMAGE_TAG = "${IMAGE_NAME}:${BUILD_NUMBER}"
    }
    stages {
        stage('Setup') {
            steps {
                sh "pip install flask || true" 
            }
        }
        
        stage('Package code') {
            steps {
                sh "zip -r myapp.zip ./* -x '**.git**'"
                sh "ls -lart"
            }
        }
        
        stage('Parallel Deploy & Build') {
            parallel {
                stage('Deploy to Prod') {
                    steps {
                        script {
                            def remote_user = "rahul"
                            def ssh_key = "/var/lib/jenkins/.ssh/id_rsa"
                            
                            // Create the deployment script
                            writeFile file: 'deploy.sh', text: """#!/bin/bash
                            set -e
                            unzip -o /home/rahul/myapp.zip -d /home/rahul/app/
                            source /home/rahul/app/venv/bin/activate
                            cd /home/rahul/app/
                            pip install flask
                            sudo systemctl restart flaskapp.service
                            """
                            
                            sh """
                                # Transfer zip and script
                                scp -i ${ssh_key} -o StrictHostKeyChecking=no myapp.zip ${remote_user}@${SERVER_IP}:/home/rahul/
                                scp -i ${ssh_key} -o StrictHostKeyChecking=no deploy.sh ${remote_user}@${SERVER_IP}:/home/rahul/
                                
                                # Execute script
                                ssh -i ${ssh_key} -o StrictHostKeyChecking=no ${remote_user}@${SERVER_IP} "bash /home/rahul/deploy.sh"
                            """
                        }
                    }
                }
                
                stage('Build Docker Image') {
                    steps {
                        script {
                            echo 'Building Docker Image...'
                            sh "docker build -t ${IMAGE_TAG} ."
                            sh "docker image ls | grep ${IMAGE_NAME}"
                        }
                    }
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-creds', 
                                                      usernameVariable: 'DOCKER_USER', 
                                                      passwordVariable: 'DOCKER_PASS')]) {
                        def dockerLogin = "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        
                        // Mask the password in logs
                        sh dockerLogin
                        
                        echo 'Logged in successfully. Pushing image...'
                        sh "docker push ${IMAGE_TAG}"
                        
                        // Tag as latest as well for convenience
                        sh "docker tag ${IMAGE_TAG} ${IMAGE_NAME}:latest"
                        sh "docker push ${IMAGE_NAME}:latest"
                    }
                }
            }
        }
    }
}
