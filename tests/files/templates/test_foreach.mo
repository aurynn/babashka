{{#babashka.mo.foreach "FOREACH_VARIABLES" "as" "var"}}
  - {{var.name}}
  - {{var.value}}
{{/babashka.mo.foreach "FOREACH_VARIABLES" "as" "var"}}