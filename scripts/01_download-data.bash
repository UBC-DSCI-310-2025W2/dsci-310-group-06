mkdir -p data

curl -L -o data/stroke-prediction-dataset.zip\
  https://www.kaggle.com/api/v1/datasets/download/fedesoriano/stroke-prediction-dataset
  
unzip -o data/stroke-prediction-dataset.zip -d data/

rm data/stroke-prediction-dataset.zip