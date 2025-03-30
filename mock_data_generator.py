import boto3
import json
import random

kinesis = boto3.client('kinesis', region_name='ap-south-1')
sample_tweets = ["I love AWS!", "This project is hard...", "Terraform rocks!"]

while True:
    tweet = random.choice(sample_tweets)
    kinesis.put_record(
        StreamName="social-media-stream",
        Data=json.dumps({"text": tweet}),
        PartitionKey="1"
    )