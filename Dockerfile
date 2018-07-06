FROM alpine

RUN apk add --no-cache curl make py2-pip python3 py-setuptools openjdk8-jre-base &&\
	pip2 install wheel && pip3 install wheel &&\
	curl http://central.maven.org/maven2/io/swagger/swagger-codegen-cli/2.2.3/swagger-codegen-cli-2.2.3.jar \
		>/swagger-codegen-cli.jar

WORKDIR /_
COPY api api
COPY python python

RUN cd python &&\
	java -DapiTests=false -DmodelTests=false \
		-jar /swagger-codegen-cli.jar generate \
		-i ../api/suite-proxy-v1.yaml \
		-l python \
		-c cg-v1.json \
		-o fastscore &&\
	java -DapiTests=false -DmodelTests=false \
		-jar /swagger-codegen-cli.jar generate \
		-i ../api/suite-proxy-v2.yaml \
		-l python \
		-c cg-v2.json \
		-o fastscore &&\
	rm -rf build && python2 setup.py bdist_wheel &&\
	rm -rf build && python3 setup.py bdist_wheel
## TODO:
##   python2 setup.py test
##   python3 setup.py test
