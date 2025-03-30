variable "aws_region" {
  description = "AWS Region"
  default = "ap-south-1"
}

variable "kinesis_stream_name" {
  default = "social-media-stream"
}

variable "lambda_function_name" {
  default = "sentiment-analysis"
}