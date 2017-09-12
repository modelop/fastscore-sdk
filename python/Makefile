
.PHONY: default v1-api v2-api

OUT_DIR := fastscore/api

JAVA_OPTS := -DapiTests=false -DmodelTests=false

default: docs

v1-api: ../api/suite-proxy-v1.yaml
	mkdir -p fastscore/api
	java $(JAVA_OPTS) -jar ~/bin/swagger-codegen-cli.jar generate \
    -i $^ \
    -l python \
    -c cg-v1.json \
    -o $(OUT_DIR) \

v2-api: ../api/suite-proxy-v2.yaml
	mkdir -p fastscore/api
	java $(JAVA_OPTS) -jar ~/bin/swagger-codegen-cli.jar generate \
    -i $^ \
    -l python \
    -c cg-v2.json \
    -o $(OUT_DIR) \

SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SPHINXPROJ    = FastScoreSDK
SOURCEDIR     = docs/source
BUILDDIR      = docs/build

docs: Makefile
	@$(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
