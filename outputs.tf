output "kines_stream_arn" {
  value = aws_kinesis_stream.social_media_stream.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.sentiment_analysis.function_name
}