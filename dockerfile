FROM golang:1.16.3-alpine3.13

RUN apk update 
RUN apk upgrade 
RUN apk add gopass

ENTRYPOINT ["gopass", "--version"]
