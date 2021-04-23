FROM python:3.8

COPY ./api_trt/api /usr/src/api

COPY ./api_trt/workers /usr/src/workers

COPY ./api_trt/config.py /usr/src/

COPY ./api_trt/main_test.py /usr/src/

COPY ./requirements-api.txt /usr/src/

RUN pip3 install --upgrade pip

RUN pip3 install -r /usr/src/requirements-api.txt

WORKDIR /usr/src

# CMD gunicorn --bind 0.0.0.0:5001 api_trt.main_test:app -w 4 -k uvicorn.workers.UvicornWorker --reload --access-logfile - --error-logfile - --log-level info
