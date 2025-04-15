from pydantic import Field
from pydantic_settings import BaseSettings


class OcrConfig(BaseSettings):
    OCR_SERVICE_ENABLED: bool = Field(
        description="Enable debug ocr",
        default=False,
    )

    OCR_SERVICE_URL: str = Field(
        description="Path for ocr service url.",
        default="",
    )