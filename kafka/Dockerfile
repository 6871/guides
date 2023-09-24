# docker build --tag kafka:2.13-3.5.1 .
# docker rmi kafka:2.13-3.5.1
# docker run --rm --tty --interactive kafka:2.13-3.5.1
FROM ubuntu:latest
ENV INSTALL_DIR='/kafka'
RUN mkdir -p "${INSTALL_DIR:?}"
COPY install.sh "${INSTALL_DIR:?}/install.sh"

RUN apt-get update \
    && apt-get install --yes \
        gpg \
        curl \
        openjdk-19-jdk-headless \
    && cd "${INSTALL_DIR:?}" \
    && /kafka/install.sh

WORKDIR "${INSTALL_DIR:?}/kafka_2.13-3.5.1"
