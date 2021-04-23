from os.path import dirname, join, realpath
import sys
CURRENT_DIR = dirname(realpath(__file__))
PARENT_DIR = dirname(CURRENT_DIR)
sys.path.insert(0, PARENT_DIR)

try:
    from modules.processing import Processing
except Exception as ex:
    print(ex)    
    

from celery import Celery
import logging
from celery import Task
from celery.exceptions import MaxRetriesExceededError
try: 
    from config import BACKEND_CONN_URI, BROKER_CONN_URI, REDIS_STORE_CONN_URI
    from env_parser import EnvConfigs
except:
     from api_trt.config import BACKEND_CONN_URI, BROKER_CONN_URI, REDIS_STORE_CONN_URI
     from api_trt.env_parser import EnvConfigs
import redis

configs = EnvConfigs()

celery_ = Celery('celery', broker=BROKER_CONN_URI, backend=BACKEND_CONN_URI)
redis_store = redis.Redis.from_url(REDIS_STORE_CONN_URI)

# class Task(BaseModel):
#     task_id: str
#     status: str

# class Prediction(Task):
#     task_id: str
#     status: str
#     result: str


class PredictTask(Task):
    def __init__(self):
        super().__init__()
        self.processing = None

    def __call__(self, *args, **kwargs):
        if not self.processing:
            logging.info('Loading Model...')
            self.processing = Processing(det_name=configs.models.det_name, rec_name=configs.models.rec_name,
                        ga_name=configs.models.ga_name,
                        device=configs.models.device,
                        max_size=configs.defaults.max_size,
                        max_rec_batch_size=configs.models.rec_batch_size,
                        backend_name=configs.models.backend_name,
                        force_fp16=configs.models.fp16)
            logging.info('Model loaded')
        return self.run(*args, **kwargs)


@celery_.task(ignore_result=False, bind=True, base=PredictTask)
def get_embedding(self, images, max_size, return_face_data,
                                      embed_only, extract_embedding,
                                      threshold, extract_ga,
                                      return_landmarks, api_ver):
    try:
        data_pred = self.processing.extract_(images, max_size, return_face_data,
                                      embed_only, extract_embedding,
                                      threshold, extract_ga,
                                      return_landmarks, api_ver)
        print("results....")
        return data_pred
    except Exception as ex:
        try:
            self.retry(countdown=2)
        except MaxRetriesExceededError as ex:
            return {'status': 'FAIL', 'result': 'max retried achieved'}


@celery_.task
def move_to_next_stage(name, stage):
    redis_store.set(name, stage)
    return stage

