provider "aws" {
  region = var.aws_region
}

#kinesis data stream --->>>>>
resource "aws_kinesis_stream" "social_media_stream" {
  name        = var.kinesis_stream_name
  shard_count = 1
  encryption_type = "NONE" 
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Redshift Serverless --->>>>>
resource "aws_redshiftserverless_namespace" "sentiment_ns" {
  namespace_name      = "sentiment-analysis-ns"
  admin_username      = "adminuser"  # Explicit username
  admin_user_password = "YourSecurePassword123!" # Must meet complexity requirements
  iam_roles           = [aws_iam_role.lambda_role.arn]  # Add this line
}

resource "aws_redshiftserverless_workgroup" "sentiment_wg" {
  workgroup_name = "sentiment-analysis-wg"
  namespace_name = aws_redshiftserverless_namespace.sentiment_ns.namespace_name
}

# Updated create_table resource
resource "aws_redshiftdata_statement" "create_table" {
  workgroup_name = aws_redshiftserverless_workgroup.sentiment_wg.workgroup_name
  database       = "dev"
  sql            = <<SQL
    CREATE TABLE IF NOT EXISTS sentiment_results (
      text VARCHAR(5000),
      sentiment VARCHAR(20),
      created_at TIMESTAMP DEFAULT GETDATE()
    );
    
    GRANT USAGE ON SCHEMA public TO adminuser;
    GRANT SELECT, INSERT, UPDATE, DELETE ON sentiment_results TO adminuser;
  SQL

  depends_on = [aws_redshiftserverless_workgroup.sentiment_wg]
}