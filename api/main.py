import os

import boto3
import requests
from fastapi import FastAPI
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.botocore import BotocoreInstrumentor
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.sdk.extension.aws.trace import AwsXRayIdGenerator
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

# Sends generated traces in the OTLP format to an ADOT Collector running on port 4317
otlp_exporter = OTLPSpanExporter(
    endpoint=os.environ.get("OTLP_EXPLORTER_ENDPOINT"),
    insecure=True,
)

# Processes traces in batches as opposed to immediately one after the other
span_processor = BatchSpanProcessor(otlp_exporter)
# Configures the Global Tracer Provider
trace.set_tracer_provider(
    TracerProvider(
        active_span_processor=span_processor,
        id_generator=AwsXRayIdGenerator(),
    ),
)

RequestsInstrumentor().instrument()
BotocoreInstrumentor().instrument()

app = FastAPI()
tracer = trace.get_tracer(__name__)


@app.get("/ping")
def ping() -> str:
    return "pong"


@tracer.start_as_current_span("_long_execute_def")
def _long_execute_def() -> None:
    import time

    time.sleep(1)


@app.get("/otel-test")
def otel_test() -> dict:
    response = requests.get(url="https://google.com/", timeout=30)
    response.raise_for_status()

    s3 = boto3.client("s3", region_name="ap-northeast-1")
    s3.list_buckets()

    _long_execute_def()

    return {"Hello": "World"}


@app.get("/api")
def read_root() -> dict:
    return {"Hello": "World"}


FastAPIInstrumentor.instrument_app(
    app=app,
)
