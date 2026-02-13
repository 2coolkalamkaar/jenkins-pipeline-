pipeline {
    agent any
    environment {
        SERVER_IP = credentials('prod-dash-server-dash-IP') // Using stored IP credential
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
    }
}
