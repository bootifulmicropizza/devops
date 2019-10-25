# TODO create 'jenkins' user with programmatic access

resource "aws_iam_policy" "jenkins_service_account_policy" {
  name        = "JenkinsServiceAccountPolicy"
  path        = "/"
  description = "Jenkins Service Account IAM Policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:eu-west-1:${var.aws_account}:parameter/jenkins/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:DescribeKey",
                "kms:Decrypt"
            ],
            "Resource": "arn:aws:kms:eu-west-1:${var.aws_account}:key/*"
        }
    ]
}
EOF
}

data "aws_iam_policy_document" "jenkins_service_account_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.openIdProviderUrl, "https://", "")}:sub"
      values   = ["system:serviceaccount:devops:bootifulmicropizza-jenkins"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.openIdProviderUrl, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [var.openIdProviderArn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "jenkins_service_account_role" {
  assume_role_policy = data.aws_iam_policy_document.jenkins_service_account_policy.json
  name               = "BootifulMicroPizzaJenkinsServiceAccount"
}

resource "aws_iam_role_policy_attachment" "jenkins_service_account_role_policy_attachment" {
  role       = aws_iam_role.jenkins_service_account_role.name
  policy_arn = aws_iam_policy.jenkins_service_account_policy.arn
}

