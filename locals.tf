locals {
  tags            = merge(var.tags, {module_name = "tf-module-vpc"})
  vpc_tags        = merge(local.tags, { Name = "${var.env}-vpc" })
  lb_subnet_tags  = merge(local.tags, { Name = "${var.env}-lb-subnet" })
  eks_subnet_tags = merge(local.tags, { Name = "${var.env}-eks-subnet" })
  db_subnet_tags  = merge(local.tags, { Name = "${var.env}-db-subnet" })
}