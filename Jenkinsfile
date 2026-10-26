pipeline {
  agent any

  options {
    disableConcurrentBuilds()
  }

  parameters {
    string(
      name: 'AMI_ID',
      defaultValue: 'ami-021aaf3749be66813',
      description: 'AWS AMI ID to use for the EC2 instance'
    )
    string(
      name: 'INSTANCE_TYPE',
      defaultValue: 't3.micro',
      description: 'EC2 instance type'
    )
    string(
      name: 'KEY_NAME',
      defaultValue: 'devops',
      description: 'Existing AWS EC2 key pair name'
    )
  }

  environment {
    AWS_DEFAULT_REGION = 'eu-north-1'
    TF_IN_AUTOMATION = 'true'
    TF_VAR_ami_id = "${params.AMI_ID}"
    TF_VAR_instance_type = "${params.INSTANCE_TYPE}"
    TF_VAR_key_name = "${params.KEY_NAME}"
  }

  stages {
    stage('Terraform Init and Validate') {
      when {
        expression {
          env.BRANCH_NAME == 'main' || env.GIT_BRANCH == 'origin/main' || env.GIT_BRANCH == 'main'
        }
      }
      steps {
        withCredentials([
          string(credentialsId: 'AWS_ACCESS_KEY', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'AWS_SECRET_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
        ]) {
          script {
            if (isUnix()) {
              sh 'terraform init -input=false && terraform validate'
            } else {
              bat 'terraform init -input=false && terraform validate'
            }
          }
        }
      }
    }

    stage('Terraform Plan and Apply') {
      when {
        expression {
          env.BRANCH_NAME == 'main' || env.GIT_BRANCH == 'origin/main' || env.GIT_BRANCH == 'main'
        }
      }
      steps {
        withCredentials([
          string(credentialsId: 'AWS_ACCESS_KEY', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'AWS_SECRET_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
        ]) {
          script {
            if (isUnix()) {
              sh 'terraform plan -input=false -out=tfplan && terraform apply -input=false -auto-approve tfplan'
            } else {
              bat 'terraform plan -input=false -out=tfplan && terraform apply -input=false -auto-approve tfplan'
            }
          }
        }
      }
      post {
        always {
          script {
            if (fileExists('tfplan')) {
              if (isUnix()) {
                sh 'rm -f tfplan'
              } else {
                bat 'if exist tfplan del /f /q tfplan'
              }
            }
          }
        }
      }
    }
  }
}
