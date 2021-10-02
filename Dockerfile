FROM codingforentrepreneurs/python:3.9-webapp-cassandra

COPY app app
COPY requirements.txt /app/requirements.txt
COPY ./entrypoint.sh ./app/entrypoint.sh
COPY ./pipelines /app/pipelines

WORKDIR /app

RUN chmod +x entrypoint.sh

RUN python3 -m venv /opt/venv && /opt/venv/bin/python -m pip install -r requirements.txt

RUN /opt/venv/bin/python -m pypyr /app/pipelines/sms-spam-model-download

CMD [ "./entrypoint.sh" ]