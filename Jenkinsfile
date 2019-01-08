node {
    stage('Preparation'){
    env.MONGO_VAR = "pip_test_mongo"
    env.docker_network="jobfinder_network"	    
    env.dbname="jobfinder"
    env.prefix_name="pip_env_backend"
    env.image_name="pip_env_backend"
    env.forwarded_port_app=15000
    env.thisDir="/opt/CI_jobfinder/devops_env/backend/" // home/azaitsau/Jenkins_Pipeline/
    }

 	// Clean workspace before doing anything
    deleteDir()

    try {
        stage ('Clone') {
        	checkout scm
        }
	stage ('Delete old containers before starting')
	     sh "docker stop $MONGO_VAR && docker rm $MONGO_VAR"
	     sh "docker stop $image_name && docker rm $image_name"
        stage ('Build and Run Mongo:3.6') {
  		    sh "docker run -d -t --name $MONGO_VAR --hostname $MONGO_VAR --network $docker_network mongo:3.6"
	}	   
	stage ('Import Mongo Collections') {
	            sh "docker cp $thisDir/mongo/mongo_collections $MONGO_VAR:/opt/"
		    def importMongoCollections = '''\
                        local list_of_collections=($(docker exec $MONGO_VAR ls /opt/mongo_collections))
                        for collection_json_name in ${list_of_collections[*]}
                        do
                        only_name=${collection_json_name%.*}
                        docker exec $MONGO_VAR mongoimport -d $dbname -c $only_name /opt/mongo_collections/$collection_json_name
                        done
                     '''
	}	
	stage ('Build an Application') {
		dir ('/opt/CI_jobfinder/devops_env/backend/'){	
		    sh "docker build -t $image_name ."
		}	
        }
	stage ('Run an Application') {
 		    sh "docker run -d -v $WORKSPACE:/opt/project_volume/ -p $forwarded_port_app:8080 --network $docker_network --hostname $image_name --name $image_name $image_name"	
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
