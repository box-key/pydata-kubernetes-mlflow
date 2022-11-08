from flask import Flask, request
from flask_restful import Resource, Api
from sklearn.ensemble import RandomForestClassifier

import logging


logging.basicConfig(
    format="%(asctime)s %(levelname)-8s [%(filename)s:%(lineno)d] %(message)s",
    level=logging.DEBUG,
)
logger = logging.getLogger(__name__)


class IrisRandomForestPredictor(Resource):
    def __init__(self, **kwargs):
        self.model: RandomForestClassifier = kwargs["model"]

    def post(self):
        payload = request.get_json()
        if payload is None:
            resp = {"status": 400, "message": "empty input"}
            return resp
        logger.debug(f"{payload=}")
        try:
            input_arr = [
                float(payload["sepal_length"]),
                float(payload["sepal_width"]),
                float(payload["petal_length"]),
                float(payload["petal_width"]),
            ]
            prediction = self.model.predict([input_arr])
            return {
                "status": 200,
                "message": "successfully processed request",
                "data": {"predicted_label": int(prediction[0])},
            }
        except KeyError:
            return {"status": 400, "message": "missing input fields"}
        except ValueError:
            return {"status": 400, "message": "illegal input type"}


def create_app():
    import mlflow
    import os

    # get model name and version
    model_name = os.getenv("MLFLOW_MODEL_NAME")
    model_version = os.getenv("MLFLOW_MODEL_VERSION")
    mlflow_uri = os.getenv("MLFLOW_URI")
    # load model
    logger.info(f"Loading {model_name=} | {model_version=}")
    mlflow.set_tracking_uri(mlflow_uri)
    model = mlflow.sklearn.load_model(f"models:/{model_name}/{model_version}")
    # init flask
    app = Flask(__name__)
    api = Api(app)
    api.add_resource(
        IrisRandomForestPredictor,
        "/predict",
        resource_class_kwargs={"model": model},
    )
    logger.info("Service ready!")
    return app
