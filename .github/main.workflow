workflow "Push" {
  on       = "push"

  resolves = [
    "deploy"
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
  uses  = "actions/bin/filter@master"
  args  = "branch master"

  needs = [
    "test"
  ]
}

action "build" {
  uses  = "actions/npm@master"
  args  = "run build"

  needs = [
    "test"
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
