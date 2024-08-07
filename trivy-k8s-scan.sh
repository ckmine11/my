#!/bin/bash
#trivy-k8s-scan

echo $imageName #getting Image name from env variable

#docker run --rm   -v  /var/run/docker.sock:/var/run/docker.sock -v $WORKSPACE:/root/.cache/ aquasec/trivy -q image  --exit-code 0 --severity LOW,MEDIUM,HIGH --light $imageName
docker run --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock:ro -v $WORKSPACE:/root/.cache/ aquasec/trivy  -q image --exit-code 0 --severity LOW,MEDIUM,HIGH --light $imageName

#docker run --rm  -v  /var/run/docker.sock:/var/run/docker.sock -v $WORKSPACE:/root/.cache/ aquasec/trivy -q image  --exit-code 1 --severity CRITICAL --light $imageName
docker run --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock:ro -v $WORKSPACE:/root/.cache/ aquasec/trivy -q image --exit-code 0 --severity CRITICAL --light $imageName

    # Trivy scan result processing
    exit_code=$?
    echo "Exit Code : $exit_code"

    # Check scan results
    if [[ ${exit_code} == 1 ]]; then
        echo "Image scanning failed. Vulnerabilities found"
        exit 1;
    else
        echo "Image scanning passed. No vulnerabilities found"
    fi;
