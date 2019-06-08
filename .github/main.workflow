workflow "Deploy" {
  on       = "push"

  resolves = [
    "deploy"
  ]
}

workflow "Pull Request" {
  on       = "pull_request"

  resolves = [
    "test"
  ]
}

action "install" {
  uses = "actions/npm@master"
  args = "install"
}

action "test" {
  uses  = "actions/npm@master"
  args  = "run test:unit"

  needs = [
    "install"
  ]
}

action "is-branch-master" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "build" {
  uses  = "actions/npm@master"
  args  = "run build"

  needs = [
    "is-branch-master"
  ]
}

action "deploy" {
  uses    = "peaceiris/actions-gh-pages@v1.0.1"

  secrets = [
    "ACTIONS_DEPLOY_KEY"
  ]

  needs   = [
    "build"
  ]

  env     = {
    PUBLISH_DIR    = "./dist"
    PUBLISH_BRANCH = "gh-pages"
  }
}
