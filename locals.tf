locals {
  tags            = merge(var.tags, {module_name = "tf-module-vpc"})
  vpc_tags        = merge(local.tags, { Name = "${var.env}-vpc" })
}