aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $1.dkr.ecr.eu-west-1.amazonaws.com
docker build -t build-tools .
docker tag build-tools:latest $1.dkr.ecr.eu-west-1.amazonaws.com/build-tools:latest
docker push $1.dkr.ecr.eu-west-1.amazonaws.com/build-tools:latest
