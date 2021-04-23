FROM python:3.8

COPY ./api_trt/workers /usr/src/workers

COPY ./api_trt/env_parser.py /usr/src/

COPY ./api_trt/modules /usr/src/modules

COPY ./api_trt/env_parser.py /usr/src/

COPY ./api_trt/__init__.py /usr/src/

COPY ./api_trt/config.py /usr/src/

COPY ./requirements-celery.txt /usr/src/

RUN pip3 install --upgrade pip

RUN pip3 install -r /usr/src/requirements-celery.txt

WORKDIR /usr/src

EXPOSE 6379 5672

# CMD celery worker -A api_trt.workers.worker --loglevel=info --logfile=%p.log -n anhlbt@%h -E
