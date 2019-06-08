# =============================================================================
# プルリクエスト
# =============================================================================
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

# =============================================================================
# デプロイ
# =============================================================================
workflow "Deploy" {
  on       = "push"

  resolves = [
    "deploy"
  ]
}

action "is-branch-master" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "pre-install" {
  uses  = "actions/npm@master"
  args  = "install"

  needs = [
    "is-branch-master"
  ]
}

action "pre-test" {
  uses  = "actions/npm@master"
  args  = "run test:unit"

  needs = [
    "pre-install"
  ]
}

action "build" {
  uses  = "actions/npm@master"
  args  = "run build"

  needs = [
    "pre-test"
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
