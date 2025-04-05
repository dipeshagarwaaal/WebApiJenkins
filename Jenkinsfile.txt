pipeline {
    agent any
    environment {
        AZURE_CREDENTIALS_ID = 'jenkins-pipeline-sp'
        RESOURCE_GROUP = 'WebServiceResourceforReactProject'
        APP_SERVICE_NAME = 'AgarwalReactWebApp'
        TF_WORKING_DIR='.'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'master', url: 'https://github.com/dipeshagarwaaal/Personal-Blog.git'
            }
        }
         stage('Terraform Init') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat """
                    echo "Checking Terraform Installation..."
                    terraform -v
                    echo "Navigating to Terraform Directory: $TF_WORKING_DIR"
                    cd $TF_WORKING_DIR
                    echo "Initializing Terraform..."
                    terraform init
                    """
                }
            }
        }

        stage('Terraform Plan') {
    steps {
        withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
            bat """
            echo "Navigating to Terraform Directory: %TF_WORKING_DIR%"
            cd %TF_WORKING_DIR%
            terraform plan -out=tfplan
            """
        }
    }
}


        stage('Terraform Apply') {
    steps {
        withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
            bat """
            echo "Navigating to Terraform Directory: %TF_WORKING_DIR%"
            cd %TF_WORKING_DIR%
            echo "Applying Terraform Plan..."
            terraform apply -auto-approve tfplan
            """
        }
    }
}

    

        stage('Build') {
            steps {
                bat 'npm install'
                bat 'npm run build'
            }
        }

       stage('Deploy') {
    steps {
        withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
            bat """
            powershell Compress-Archive -Path build/* -DestinationPath build.zip -Force
            az webapp deploy --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --src-path build.zip --type zip
            """
        }
    }
}

    }

    post {
        success {
            echo 'Deployment Successful!'
        }
        failure {
            echo 'Deployment Failed!'
        }
    }
}
