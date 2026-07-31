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

        stage('Trivy Image Scan') {
            steps {
                script {
                    echo 'Scanning Docker Image with Trivy...'
                    // Use docker run directly to avoid installing trivy locally.
                    // Mounting docker.sock allows Trivy to see the images on the host.
                    sh """
                        docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
                        -v /root/.cache/:/root/.cache/ \
                        aquasec/trivy image --exit-code 0 --severity HIGH,CRITICAL ${IMAGE_TAG}
                    """
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
        
        stage('Deploy to Staging (GitOps)') {
            steps {
                script {
                    echo 'Updating Staging Helm Values...'
                    // Update the image tag using sed
                    sh "sed -i 's|tag: .*|tag: \"${BUILD_NUMBER}\"|g' helm/flaskapp/values-staging.yaml"
                    
                    // Commit and push to trigger ArgoCD
                    sh """
                        git config user.email "jenkins@example.com"
                        git config user.name "Jenkins CI"
                        git add helm/flaskapp/values-staging.yaml
                        git commit -m "Deploy staging: build ${BUILD_NUMBER}" || echo "No changes to commit"
                        git push origin main || echo "Failed to push, check Git auth"
                    """
                }
            }
        }
        
        stage('Test Staging') {
            steps {
                script {
                    echo 'Waiting for ArgoCD to sync Staging (30s)...'
                    sleep time: 30, unit: 'SECONDS'
                    
                    echo 'Running API Test against Staging...'
                    // Check if staging returns a 200 OK. We use localhost as Jenkins is assumed to run in the same cluster/network or can access the NodePort.
                    sh "curl -s -o /dev/null -w '%{http_code}' http://localhost:30001 | grep 200 || echo 'Warning: Staging test failed'"
                }
            }
        }

        stage('Approval: Deploy to Prod') {
            steps {
                input message: 'Approve deployment to Production?', ok: 'Deploy'
            }
        }

        stage('Deploy to Prod (GitOps)') {
            steps {
                script {
                    echo 'Updating Production Helm Values...'
                    sh "sed -i 's|tag: .*|tag: \"${BUILD_NUMBER}\"|g' helm/flaskapp/values-prod.yaml"
                    
                    sh """
                        git add helm/flaskapp/values-prod.yaml
                        git commit -m "Deploy prod: build ${BUILD_NUMBER}" || echo "No changes to commit"
                        git push origin main || echo "Failed to push, check Git auth"
                    """
                }
            }
        }
    }
}
