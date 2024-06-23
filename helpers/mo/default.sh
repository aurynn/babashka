## Babashka + Mo function to allow for default values to be passed and used in
# the templating stage. This is necessary because Mo does not have a built-in
# "if not set, use default value" functionality.
# Ideally this would be in the Mo parser, but it is not, so, we have
# to do it like this.

function babashka.mo.default() {
  echo "${1:-$2}"
}