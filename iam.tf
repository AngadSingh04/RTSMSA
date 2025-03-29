# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-sentiment-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Custom Policy for Kinesis, Comprehend, and Redshift
resource "aws_iam_policy" "lambda_permissions" {
  name        = "lambda-sentiment-policy"
  description = "Permissions for Lambda to access Kinesis, Comprehend, and Redshift"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:DescribeStream"
        ],
        Resource = aws_kinesis_stream.social_media_stream.arn
      },
      {
        Effect = "Allow",
        Action = "comprehend:DetectSentiment",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "redshift-data:ExecuteStatement",
          "redshift-serverless:GetCredentials"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach Policies to Role
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_custom" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_permissions.arn
}