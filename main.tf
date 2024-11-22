terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.24"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.77"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

data "aws_db_instance" "example" {
  db_instance_identifier = "testdbinstance"
}

ephemeral "aws_secretsmanager_secret_version" "db_master" {
  secret_id = data.aws_db_instance.example.master_user_secret[0].secret_arn
}
locals {
  credentials = jsondecode(ephemeral.aws_secretsmanager_secret_version.db_master.secret_string)
}

provider "postgresql" {
  host     = data.aws_db_instance.example.address
  port     = data.aws_db_instance.example.port
  username = local.credentials["username"]
  password = local.credentials["password"]
}

resource "random_pet" "example" {}

resource "postgresql_database" "db" {
  name = random_pet.example.id
}
