FROM alpine

RUN apk add --no-cache curl make py-setuptools openjdk8-jre-base

RUN mkdir /root/bin &&\
	curl http://central.maven.org/maven2/io/swagger/swagger-codegen-cli/2.2.3/swagger-codegen-cli-2.2.3.jar >\
		/root/bin/swagger-codegen-cli.jar

WORKDIR /_
COPY api api
COPY python python

RUN make -C python
