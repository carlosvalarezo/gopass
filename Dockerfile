FROM alpine:3.13.4

RUN apk update
RUN apk upgrade
RUN apk add --no-cache bash=5.1.0-r0 openssh-client=8.4_p1-r3 xclip=0.13-r1 go=1.15.10-r0 gopass=1.9.2-r0


ENTRYPOINT ["go", "version"]