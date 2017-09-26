
.PHONY: default v1-api v2-api clean build

OUT_DIR := fastscore

JAVA_OPTS := -DapiTests=false -DmodelTests=false

default: docs

v1-api: ../api/suite-proxy-v1.yaml
	java $(JAVA_OPTS) -jar ~/bin/swagger-codegen-cli.jar generate \
    -i $^ \
    -l python \
    -c cg-v1.json \
    -o $(OUT_DIR) \

v2-api: ../api/suite-proxy-v2.yaml
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

build:
	docker build -f ../Dockerfile.build --force-rm --build-arg uid=`id -u` --build-arg gid=`id -g` -t fastscore/sdk-build ..
	docker run --rm -v $(CURDIR)/..:/_ fastscore/sdk-build make -C python v1-api v2-api
	python setup.py sdist

clean:
	rm -rf dist *.egg-info \
		fastscore/.swagger-codegen*\
		fastscore/.travis.yml\
		fastscore/README.md\
		fastscore/docs/\
		fastscore/git_push.sh\
		fastscore/requirements.txt\
		fastscore/setup.py\
		fastscore/test-requirements.txt\
		fastscore/tox.ini\
		fastscore/v1/\
		fastscore/v2/
