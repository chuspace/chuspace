project = "chuspace"

variable "database_url" {
  type    = string
  default = dynamic("aws-ssm", {
    path = "chuspace-primary-db-connection-string"
  })
}

variable "rails_master_key" {
  type    = string
  default = dynamic("aws-ssm", {
    path = "chuspace-app-master-key"
  })
}

config {
  env = {
    DATABASE_URL = var.database_url
    RAILS_MASTER_KEY = var.rails_master_key
    REGION = "Ireland",
    RACK_ENV =  "production",
    RAILS_ENV = "production",
    RAILS_LOG_TO_STDOUT = "1",
    RAILS_SERVE_STATIC_FILES = "1",
    BOOTSNAP_CACHE_DIR =  "tmp/bootsnap-cache",
    EXECJS_RUNTIME = "Node"
  }
}

runner {
    enabled = true
}

app "web" {
    build {
        use "pack" {
            builder     = "heroku/buildpacks:20"
            disable_entrypoint = true
        }

        registry {
            use "aws-ecr" {
                region     = "eu-west-1"
                repository = "chuspace-app"
                tag        = "latest"
            }
        }
    }

    deploy {
       use "aws-ecs" {
            region = "eu-west-1"
            memory = "512"
            alb  {
                certificate = "arn:aws:acm:eu-west-1:869307293297:certificate/66d3ff29-d026-478b-8dae-fbe840b97762"
                internal = false
                subnets = ["subnet-0b1fc60914bd230e0", "subnet-0698b926c90d8b69e"]
            }
        }
    }

    url {
        auto_hostname = false
    }

}
