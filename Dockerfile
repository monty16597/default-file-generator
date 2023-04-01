# Container image that runs your code
FROM alpine:3.17.3
COPY entrypoint.sh /entrypoint.sh
RUN chmod +X /entrypoint.sh
# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]