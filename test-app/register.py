from sklearn import datasets
from sklearn.ensemble import RandomForestClassifier as rf
import mlflow
import mlflow.sklearn

import os
import logging


logging.basicConfig(
    format="%(asctime)s %(levelname)-8s [%(filename)s:%(lineno)d] %(message)s",
    level=logging.INFO,
)
logger = logging.getLogger(__name__)


# train rf classifier
logger.info("Training random forest model..")
iris = datasets.load_iris()
clf = rf()
clf.fit(iris.data, iris.target)
# save model in mlflow
logger.info("Saving trained model in mlflow..")
name = "iris-rf"
mlflow_uri = os.getenv("MLFLOW_URI")
artifact_location = os.getenv("ARTIFACT_LOCATION")
mlflow.set_tracking_uri(mlflow_uri)
# create experiment if not exist
if mlflow.get_experiment_by_name(name) is None:
    mlflow.create_experiment(name, artifact_location=artifact_location)
mlflow.set_experiment(name)
mlflow.sklearn.log_model(clf, artifact_path="sk_models")
logger.info("All done!")
