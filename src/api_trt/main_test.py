
from fastapi import FastAPI
# from api_trt.api.product import product_router
from api.product import product_router


app = FastAPI(title="Demo API", docs_url="/", version="1.0.0")

app.include_router(
    product_router,
    prefix="/product",
    tags=["Product"],
)


