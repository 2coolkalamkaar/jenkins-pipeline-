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
                    
                    sh """
                        # Transfer the zip file to the server using the stored key
                        scp -i ${ssh_key} -o StrictHostKeyChecking=no myapp.zip ${remote_user}@${SERVER_IP}:/home/rahul/

                        # SSH into the server to deploy using the stored key
                        ssh -i ${ssh_key} -o StrictHostKeyChecking=no ${remote_user}@${SERVER_IP} << EOF
                            # Unzip to the app directory
                            unzip -o /home/rahul/myapp.zip -d /home/rahul/app/
                            
                            # Activate virtual environment
                            source /home/rahul/app/venv/bin/activate
                            
                            # Install dependencies
                            cd /home/rahul/app/
                            pip install flask
                            
                            # Restart the service
                            sudo systemctl restart flaskapp.service
                        EOF
                    """
                }
            }
        }
    }
}
