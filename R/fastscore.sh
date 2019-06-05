#!/bin/bash
set -e

RScript Install_fastscore_dep.R
R CMD INSTALL fastscore.tar.gz

