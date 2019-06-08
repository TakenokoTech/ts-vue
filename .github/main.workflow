workflow "Deploy" {
  resolves = ["GitHub Action for npm", "GitHub Action for npm-1"]
  on = "push"
}

action "GitHub Action for npm" {
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  args = "test:unit"
}
