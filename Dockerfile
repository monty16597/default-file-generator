# Container image that runs your code
FROM bash:5.0-alpine3.16
RUN apk add git
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["bash", "/entrypoint.sh"]