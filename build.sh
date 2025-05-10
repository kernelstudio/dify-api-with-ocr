#!/bin/bash

# 通过代理下载基础镜像
docker pull docker.m.daocloud.io/langgenius/dify-api:1.3.1
docker tag docker.m.daocloud.io/langgenius/dify-api:1.3.1 langgenius/dify-api:1.3.1
docker rmi docker.m.daocloud.io/langgenius/dify-api:1.3.1

docker build -t langgenius/dify-api-with-ocr:1.3.1 .