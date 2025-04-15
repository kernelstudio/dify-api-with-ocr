#!/bin/bash

# 通过代理下载基础镜像
docker pull docker.m.daocloud.io/langgenius/dify-api:0.15.3
docker tag docker.m.daocloud.io/langgenius/dify-api:0.15.3 langgenius/dify-api:0.15.3
docker rmi docker.m.daocloud.io/langgenius/dify-api:0.15.3

docker build -t langgenius/dify-api-with-ocr:0.15.3 .