# The name of your project. A project typically maps 1:1 to a VCS repository.
# This name must be unique for your Waypoint server. If you're running in
# local mode, this must be unique to your machine.
project = "chuspace"

# Labels can be specified for organizational purposes.
# labels = { "foo" = "bar" }


# An application to deploy.
app "web" {
    # Build specifies how an application should be deployed. In this case,
    # we'll build using a Dockerfile and keeping it in a local registry.
    build {
        use "pack" {
            builder     = "heroku/buildpacks:20"
            disable_entrypoint = false
        }

    registry {
        use "docker" {
            image = "web"
            tag   = "latest"
            local = true
        }
    }
    }

    deploy {
        use "kubernetes" {
            probe_path = "/"
        }
    }

    release {
        use "kubernetes" {
            load_balancer = true
            port          = 3000
        }
    }

    url {
        auto_hostname = false
    }

}
