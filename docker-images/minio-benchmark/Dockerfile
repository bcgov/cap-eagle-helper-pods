FROM ubuntu:16.04

RUN useradd -d /opt/benchmark -g root benchmark

WORKDIR /opt/benchmark

RUN apt-get update && \
    apt-get install curl -y && \
    curl -o s3-benchmark https://raw.githubusercontent.com/minio/s3-benchmark/master/s3-benchmark && \
    chmod +x s3-benchmark

USER benchmark

ENTRYPOINT [ "bash" ]
