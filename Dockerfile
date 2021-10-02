FROM tensorflow/tensorflow

FROM python:3.9-slim

ARG AWS_ACCESS_KEY_ID
ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}

ARG AWS_SECRET_ACCESS_KEY
ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

ARG BUCKET_NAME
ENV BUCKET_NAME=${BUCKET_NAME}

ARG ENDPOINT_URL
ENV ENDPOINT_URL=${ENDPOINT_URL}

ARG REGION_NAME
ENV REGION_NAME=${REGION_NAME}

COPY ./app ./app/app/
COPY requirements-prod.txt /app/requirements.txt
COPY ./entrypoint.sh ./app/entrypoint.sh
COPY ./pipelines /app/pipelines

WORKDIR /app

RUN chmod +x entrypoint.sh

RUN python3 -m venv /opt/venv && /opt/venv/bin/python -m pip install -r requirements.txt

RUN /opt/venv/bin/python -m pypyr /app/pipelines/sms-spam-model-download



CMD [ "./entrypoint.sh" ]
