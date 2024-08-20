FROM ubuntu:latest
WORKDIR /pandoc

RUN apt-get update && \
    apt-get install --yes \
      pandoc \
      fonts-noto \
      fonts-noto-color-emoji \
      fonts-dejavu-core

COPY ./templates /pandoc/templates/

ENTRYPOINT ["pandoc", "-"]
CMD []
