project = "chuspace"

config {
    runner {
        env =  {
            RAILS_MASTER_KEY = "foobar"
            RAILS_ENV = "production"
            RACK_ENV = "production"
            DATABASE_URL = dynamic("aws-ssm", {
                path = "chuspace-primary-db-connection-string"
            })
        }
    }
}

runner {
  enabled = true

  data_source "git" {
    url  = "https://github.com/chuspace/chuspace.git"
    path = ""
  }
}

app "web" {
    config {
        env = {
            DATABASE_URL = dynamic("aws-ssm", {
                path = "chuspace-primary-db-connection-string"
            })
            RAILS_MASTER_KEY = dynamic("aws-ssm", {
                path = "chuspace-app-master-key"
            })
            REGION = "Ireland",
            RACK_ENV =  "production",
            RAILS_ENV = "production",
            RAILS_LOG_TO_STDOUT = "1",
            RAILS_SERVE_STATIC_FILES = "1",
            BOOTSNAP_CACHE_DIR =  "tmp/bootsnap-cache",
            EXECJS_RUNTIME = "Node"
        }
    }

    build {
        use "pack" {
            builder     = "heroku/buildpacks:20"
            disable_entrypoint = false
        }

        registry {
            use "aws-ecr" {
                region     = "eu-west-1"
                repository = "chuspace"
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
