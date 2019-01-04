node {
    stage('Preparation'){
    env.MONGO_VAR = "pip_test_mongo"
    }

 	// Clean workspace before doing anything
    deleteDir()

    try {
        stage ('Clone') {
        	checkout scm
        }
        stage ('Build') {
		dir ('/home/azaitsau/Jenkins_Pipeline/'){
        	    sh "pwd"
		    sh "docker run -d -t --name $MONGO_VAR mongo:3.6"	
		    sh "docker build -t pip_test_back ."
		    sh "docker run -d -p 10000:8080 --name pip_test_back pip_test_back"	
		}	
        }
        stage ('Tests') {
	        parallel 'static': {
	            sh "echo 'shell scripts to run static tests...'"
	        },
	        'unit': {
	            sh "echo 'shell scripts to run unit tests...'"
	        },
	        'integration': {
	            sh "echo 'shell scripts to run integration tests...'"
	        }
        }
      	stage ('Deploy') {
            sh "echo 'shell scripts to deploy to server...'"
      	}
    } catch (err) {
        currentBuild.result = 'FAILED'
        throw err
    }
}
