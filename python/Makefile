build: v1-api v2-api
	python setup.py sdist

v1-api: ../api/suite-proxy-v1.yaml
	java -DapiTests=false -DmodelTests=false \
		-jar ~/bin/swagger-codegen-cli.jar generate \
		-i $^ \
		-l python \
		-c cg-v1.json \
		-o fastscore

v2-api: ../api/suite-proxy-v2.yaml
	java -DapiTests=false -DmodelTests=false \
		-jar ~/bin/swagger-codegen-cli.jar generate \
		-i $^ \
		-l python \
		-c cg-v2.json \
		-o fastscore

.PHONY: build v1-api v2-api
