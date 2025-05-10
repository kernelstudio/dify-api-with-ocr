# Dify 文档提取器支持自建OCR服务

Dify工作流编码中的文档提取器默认不支持提取扫描版PDF文件,为了数据安全,需[本地搭建OCR文档识别服务](https://gitee.com/kernelstudio/ocr-service)
并修改Dify相关源码.

```text
注意: 暂时只支持如下版本
```

* [1.3.1](https://gitee.com/kernelstudio/dify-api-with-ocr)
* [1.1.3](https://gitee.com/kernelstudio/dify-api-with-ocr/tree/1.1.3/)
* [0.15.3](https://gitee.com/kernelstudio/dify-api-with-ocr/tree/0.15.3/)

## 1. 添加OCR配置

首先创建[OcrConfig](./configs/__init__.py), 修改 [api/configs/app_config.py](./configs/app_config.py)

```python
# 头部导入ocr相关配置
from .ocr import OcrConfig


# 修改如下位置代码
class DifyConfig(
    # 添加ocr配置
    OcrConfig,
    # 其他配置
)
```

## 2. 修改文档提取器相关代码

添加以下ocr服务调用方法, [具体查看](./core/workflow/nodes/document_extractor/node.py#L196)

```python
import requests


def _ocr_extract_pdf(file_content: bytes) -> str:
    if dify_config.OCR_SERVICE_ENABLED and dify_config.OCR_SERVICE_URL:
        logger.info("Ocr pdf file")
        try:
            doc_file = io.BytesIO(file_content)
            files = {'file': (
                'ocr.pdf',  # 文件名
                doc_file,  # 文件流
                'application/pdf',  # 请求头Content-Type字段对应的值
                {'Expires': '0'})
            }
            response = requests.post(dify_config.OCR_SERVICE_URL, files=files)
            return response.json().get('text')
        except Exception as e:
            logger.error(e)
            return None
    return None
```

找到 `_extract_text_from_pdf` [方法](./core/workflow/nodes/document_extractor/node.py#L214)修改为如下代码:

```python
def _extract_text_from_pdf(file_content: bytes) -> str:
    # 首先调用ocr服务
    text = _ocr_extract_pdf(file_content)
    if text is not None:
        return text
    else:
        try:
            pdf_file = io.BytesIO(file_content)
            pdf_document = pypdfium2.PdfDocument(pdf_file, autoclose=True)
            text = ""
            for page in pdf_document:
                text_page = page.get_textpage()
                text += text_page.get_text_range()
                text_page.close()
                page.close()
            return text
        except Exception as e:
            raise TextExtractionError(f"Failed to extract text from PDF: {str(e)}") from e
```

## 3. 修改 `.env`

找到 `dify/docker` 目录下的 `.env`, 在文件开始位置添加如下配置:

```dotenv
# 启用ocr服务
OCR_SERVICE_ENABLED=true
# ocr服务地址
OCR_SERVICE_URL=http://ocr-service/api/v1/open/service/ocr
```

## 4. 修改 `docker-compose.yaml`

修改 `dify/docker/docker-compose.yaml`

头部添加如下配置

```yaml
x-shared-env: &shared-api-worker-env
  OCR_SERVICE_ENABLED: ${OCR_SERVICE_ENABLED:-false}
  OCR_SERVICE_URL: ${OCR_SERVICE_URL:-}
```

将此文件中的 `image: langgenius/dify-api:1.1.3` 修改为定制后的镜像名称 `image: langgenius/dify-api-with-ocr:1.1.3`

## 5. 制作镜像

```shell
sh build.sh
```

## 6. 重启服务

```shell
# 切换到具体的dify目录
cd dify/docker

docker-compose down api worker
docker-compose up -d api worker
```