docker stop mycontainer
docker rm mycontainer
docker build -t cvweb .
docker tag cvweb registry.veverka.net/cvweb
docker push registry.veverka.net/cvweb
# docker run -d --name mycontainer -p 8080:80 cvweb
# docker logs -f mycontainer
