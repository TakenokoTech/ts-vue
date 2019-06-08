workflow "Deploy" {
  on = "push"
  resolves = ["Check"]
}

action "Check" {
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  args = "test:unit"
}

workflow "PR" {
  resolves = ["Test"]
  on = "pull_request"
}

action "Test" {
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  args = "test:unit"
}
