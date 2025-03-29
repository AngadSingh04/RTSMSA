# Lambda Function
resource "aws_lambda_function" "sentiment_analysis" {
  filename      = "lambda_function.zip"
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  timeout       = 30

  environment {
    variables = {
      REDSHIFT_WORKGROUP = aws_redshiftserverless_workgroup.sentiment_wg.workgroup_name
    }
  }
}

# Kinesis Trigger for Lambda
resource "aws_lambda_event_source_mapping" "kinesis_trigger" {
  event_source_arn  = aws_kinesis_stream.social_media_stream.arn
  function_name     = aws_lambda_function.sentiment_analysis.arn
  starting_position = "LATEST"
}