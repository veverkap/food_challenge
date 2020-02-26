docker build -t meatsweatsweb .
docker tag meatsweatsweb registry.veverka.net/meatsweatsweb
docker push registry.veverka.net/meatsweatsweb
# docker run -d --name mycontainer -p 8080:80 meatsweatsweb
# docker logs -f mycontainer
