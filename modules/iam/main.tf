resource "aws_iam_role" "instance_role" {
  name        = var.iam_role
  description = var.iam_role_description

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "instance_role_policy" {
  name        = var.iam_policy
  path        = "/"
  description = var.iam_policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Effect = "Allow"
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

data "aws_iam_policy" "ssm_policy" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "instance_role_ssm_policy" {
  role       = aws_iam_role.instance_role.name
  policy_arn = data.aws_iam_policy.ssm_policy.arn
}

resource "aws_iam_role_policy_attachment" "instance_role_s3_policy" {
  role       = aws_iam_role.instance_role.name
  policy_arn = aws_iam_policy.instance_role_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "vs-ec2-master-instance-profile"
  role = aws_iam_role.instance_role.name
}
