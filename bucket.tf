# Create the S3 bucket
resource "aws_s3_bucket" "testing_bucket" {
  bucket = "phrasee-task-bucket"  # Replace with desired bucket name
}

# Create bucket object ownership
resource "aws_s3_bucket_ownership_controls" "bucket_owner_control" {
  bucket = aws_s3_bucket.testing_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Create bucket access control list
resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket_owner_control]
  bucket = aws_s3_bucket.testing_bucket.id
  acl    = "private"
}

# Configure the S3 bucket object to upload the local file
resource "aws_s3_object" "html-object" {
  bucket = aws_s3_bucket.testing_bucket.bucket
  key    = "index.html"
  acl    = "private"   
  source = "./webcontent/index.html"
}

# Configure the S3 bucket object to upload the local file
resource "aws_s3_object" "js-object" {
  bucket = aws_s3_bucket.testing_bucket.bucket
  key    = "javascript.js"
  acl    = "private"   
  source = "./webcontent/javascript.js"
}

# Configure the S3 bucket object to upload the local file
resource "aws_s3_object" "css-object" {
  bucket = aws_s3_bucket.testing_bucket.bucket
  key    = "styles.css"
  acl    = "private"   
  source = "./webcontent/styles.css"
}