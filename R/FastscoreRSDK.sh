#!/bin/bash
set -e

go get github.com/opendatagroup/fastscore-sdk-go/sdk
R CMD INSTALL FastscoreRSDK.tar.gz

