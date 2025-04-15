FROM langgenius/dify-api:0.15.3

WORKDIR /app/api

RUN mkdir -p /app/api/configs/ocr /app/api/core/workflow/nodes/document_extractor

COPY ./configs/ocr/__init__.py /app/api/configs/ocr/__init__.py
COPY ./configs/app_config.py /app/api/configs/app_config.py
COPY ./core/workflow/nodes/document_extractor/node.py /app/api/core/workflow/nodes/document_extractor/node.py

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]