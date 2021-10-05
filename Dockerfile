FROM codingforentrepreneurs/python:3.9-webapp-cassandra

COPY .env /app/.env

COPY ./app ./app/app
COPY requirements.txt /app/requirements.txt
COPY ./entrypoint.sh ./app/entrypoint.sh
COPY ./decrypt.sh ./app/decrypt.sh
COPY ./pipelines /app/pipelines
COPY .gitattributes ./app/.gitattributes

WORKDIR /app

RUN chmod +x entrypoint.sh && chmod +x decrypt.sh

RUN python3 -m venv /opt/venv && /opt/venv/bin/python -m pip install -r requirements.txt

RUN apt-get update && \
    apt-get install git-crypt -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*


RUN git init && \
    git config --global user.email "hello@teamcfe.com" && \
    git config --global user.name "Team CFE" && \
    git add --all && git commit -m "faked"


RUN bash decrypt.sh


RUN /opt/venv/bin/python -m pypyr /app/pipelines/sms-spam-model-download

CMD [ "./entrypoint.sh" ]