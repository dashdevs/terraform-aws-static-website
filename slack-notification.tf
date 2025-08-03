

# Slack notification module
module "notify_slack" {
  count  = var.cloudfront_auth && var.slack_webhook_url != null ? 1 : 0
  source = "terraform-aws-modules/notify-slack/aws"
  version = "~> 7.0"

  sns_topic_name = "${replace(var.domain, ".", "-")}-auth-notifications"

  slack_webhook_url = var.slack_webhook_url
  slack_channel     = var.slack_channel
  slack_username    = var.slack_username
  slack_emoji       = var.slack_emoji
}

# SNS topic for auth notifications
resource "aws_sns_topic" "auth_notifications" {
  count = var.cloudfront_auth && var.slack_webhook_url != null ? 1 : 0
  name  = "${replace(var.domain, ".", "-")}-auth-notifications"
}

# SNS topic subscription to Slack
resource "aws_sns_topic_subscription" "slack_notifications" {
  count     = var.cloudfront_auth && var.slack_webhook_url != null ? 1 : 0
  topic_arn = aws_sns_topic.auth_notifications[0].arn
  protocol  = "lambda"
  endpoint  = module.notify_slack[0].lambda_function_arn
}

# Lambda permission for SNS to invoke the Slack notification function
resource "aws_lambda_permission" "with_sns" {
  count         = var.cloudfront_auth && var.slack_webhook_url != null ? 1 : 0
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.notify_slack[0].lambda_function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.auth_notifications[0].arn
}

# Send notification when password changes
resource "aws_sns_topic_policy" "auth_notifications" {
  count  = var.cloudfront_auth && var.slack_webhook_url != null ? 1 : 0
  arn    = aws_sns_topic.auth_notifications[0].arn
  policy = data.aws_iam_policy_document.sns_topic_policy[0].json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  count = var.cloudfront_auth && var.slack_webhook_url != null ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    resources = [aws_sns_topic.auth_notifications[0].arn]
  }
}

# Publish notification to SNS when password changes
resource "aws_sns_topic_publish" "auth_credentials" {
  count  = var.cloudfront_auth && var.slack_webhook_url != null ? 1 : 0
  topic_arn = aws_sns_topic.auth_notifications[0].arn
  message   = jsonencode({
    text = "🔐 *New Basic Auth Credentials Generated*",
    attachments = [{
      color = "#36a64f"
      fields = [
        {
          title = "Website URL"
          value = "https://${var.domain}"
          short = true
        },
        {
          title = "Username"
          value = var.auth_username != null ? var.auth_username : "admin"
          short = true
        },
        {
          title = "Password"
          value = random_password.auth_password[0].result
          short = true
        }
      ]
      footer = "Terraform AWS Static Website Module"
      ts     = floor(timeadd(timestamp(), "0s") / 1000)
    }]
  })

  triggers = {
    password = random_password.auth_password[0].result
    domain   = var.domain
  }
} 