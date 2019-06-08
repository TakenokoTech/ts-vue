workflow "Push" {
  on       = "push"

  resolves = [
    "deploy"
  ]
}

action "install" {
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  args = "install"
}

action "test" {
  uses  = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  args  = "test"

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
  uses  = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  args  = "build"

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
