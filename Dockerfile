FROM python:3.10-alpine

WORKDIR /

RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    python3-dev \
    make \
    bash

COPY . .

RUN pip install --no-cache-dir -r requirements.txt 2>/dev/null || true
RUN pip install --no-cache-dir -r test-requirements.txt 2>/dev/null || true

RUN chmod +x run_tests.sh

CMD ["./run_tests.sh"]