FROM ubuntu:20.04

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -yq --no-install-recommends nginx-extras apache2-utils \
 && rm -rf /var/lib/apt/lists/*

COPY nginx.conf /etc/nginx/

CMD ["nginx", "-g", "daemon off;"]
