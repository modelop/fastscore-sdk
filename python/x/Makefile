
.PHONY: default v1-api

OUT_DIR := fastscore/api

JAVA_OPTS := -DapiTests=false -DmodelTests=false

default: v1-api

v1-api: suite-proxy.yaml
	java $(JAVA_OPTS) -jar ~/bin/swagger-codegen-cli.jar generate \
    -i $^ \
    -l python \
    -c cg.json \
    -o $(OUT_DIR) \

