echo 8${1}:80
docker run --rm -it --name hivetown-lb-${1} --net=lb -p 8${1}:80 -p 193${1}:1936 hivetown-lb