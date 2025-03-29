import json
import boto3
import os

comprehend = boto3.client('comprehend')
redshift = boto3.client('redshift-data')

def lambda_handler(event, context):
    for record in event['Records']:
        payload = json.loads(record['kinesis']['data'])
        text = payload['text'][:5000]  # Truncate to Comprehend limit
        
        # Sentiment Analysis
        sentiment = comprehend.detect_sentiment(
            Text=text,
            LanguageCode='en'
        )['Sentiment']
        
        # Write to Redshift
        try:
            redshift.execute_statement(
                Database='dev',
                Sql=f"""
                    INSERT INTO sentiment_results (text, sentiment)
                    VALUES ('{text.replace("'", "''")}', '{sentiment}')
                """,
                WorkgroupName=os.environ['REDSHIFT_WORKGROUP']
            )
        except Exception as e:
            print(f"Redshift Error: {str(e)}")
    
    return {"statusCode": 200}