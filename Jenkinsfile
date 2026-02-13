pipeline {
    agent any
    environment {
        SERVER_IP = "136.113.232.14" // Directly using the IP as requested
    }
    stages {
        stage('Setup') {
            steps {
                // Assuming requirements.txt exists or will be created. 
                // For now, installing flask directly as a placeholder if requirements.txt is missing.
                sh "pip install flask || true" 
            }
        }
        stage('Package code') {
            steps {
                // Zip the current directory, excluding .git
                sh "zip -r myapp.zip ./* -x '**.git**'"
                sh "ls -lart"
            }
        }
        stage('Deploy to Prod') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ssh-key', keyFileVariable: 'MY_SSH_KEY', usernameVariable: 'username')]) {
                    sh '''
                    # Transfer the zip file to the server
                    scp -i $MY_SSH_KEY -o StrictHostKeyChecking=no myapp.zip ${username}@${SERVER_IP}:/home/rahul/

                    # SSH into the server to deploy
                    ssh -i $MY_SSH_KEY -o StrictHostKeyChecking=no ${username}@${SERVER_IP} << EOF
                        # Unzip to the app directory
                        unzip -o /home/rahul/myapp.zip -d /home/rahul/app/
                        
                        # Activate virtual environment
                        source /home/rahul/app/venv/bin/activate
                        
                        # Install dependencies
                        cd /home/rahul/app/
                        # pip install -r requirements.txt # uncomment when requirements.txt exists
                        pip install flask # Ensuring flask is installed
                        
                        # Restart the service
                        sudo systemctl restart flaskapp.service
                    EOF
                    '''
                }
            }
        }
    }
}
