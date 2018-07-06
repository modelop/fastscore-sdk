build:
	docker build -t sdk-build .
	ID=`docker create sdk-build` && docker cp $$ID:/_/python/dist python && docker rm $$ID

.PHONY: build
