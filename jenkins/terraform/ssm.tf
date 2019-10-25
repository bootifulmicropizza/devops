resource "aws_ssm_parameter" "ssm_parameters" {
    for_each = toset(var.ssm_parameters)

    name  = "/jenkins/${each.value}"
    type  = "SecureString"
    value = "placeholder"

    overwrite = false
    lifecycle {
        ignore_changes = [
            value,
        ]
    }
}
