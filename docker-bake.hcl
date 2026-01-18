group "default" {
  targets = ["fullstack"]
}

target "fullstack" {
  context = "./fullstack-hy2020.github.io"
  tags    = ["fullstack:latest"]
  load    = true
}
