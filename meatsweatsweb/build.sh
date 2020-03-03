docker build -t meatsweatweb .
docker tag meatsweatweb registry.veverka.net/meatsweatweb
docker push registry.veverka.net/meatsweatweb
# docker run -d --name mycontainer -p 8080:80 meatsweatweb
# docker logs -f mycontainer
