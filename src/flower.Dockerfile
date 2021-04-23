FROM python:3.8

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y libgl1-mesa-glx protobuf-compiler libprotoc-dev libb64-0d libglib2.0-0 \
    libgomp1 gcc curl && rm -rf /var/lib/apt/lists/*

COPY ./api_trt/workers /usr/src/api_trt/workers

COPY ./api_trt/modules /usr/src/api_trt/modules

COPY ./api_trt/__init__.py /usr/src/api_trt/

COPY ./api_trt/config.py /usr/src/api_trt/

COPY ./api_trt/env_parser.py /usr/src/api_trt

COPY ./requirements-celery.txt /usr/src/

RUN pip3 install --upgrade pip

RUN pip3 install -r /usr/src/requirements-celery.txt

RUN pip3 install flower

WORKDIR /usr/src

CMD celery flower -A api_trt.workers.worker --broker=amqp://${RABBITMQ_USERNAME}:${RABBITMQ_PASSWORD}@${RABBITMQ_HOST}:${RABBITMQ_PORT}// 

# CMD celery flower -A api_trt.workers.worker --broker=amqp://${RABBITMQ_USERNAME}:${RABBITMQ_PASSWORD}@${RABBITMQ_HOST}:${RABBITMQ_PORT}//

# CMD celery worker -A api_trt.workers.worker --loglevel=info --logfile=%p.log -n anhlbt@%h

# --broker_api=http://guest:guest@${RABBITMQ_HOST}:15672/api/