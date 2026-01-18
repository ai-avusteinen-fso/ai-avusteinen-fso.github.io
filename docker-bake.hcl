group "default" {
  targets = ["fullstack"]
}

target "fullstack" {
  context = "."
  tags    = ["fullstack:latest"]
  load    = true
}
