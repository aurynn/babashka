* Fix the bootstrap script to set everything up appropriate to the new search locations, as well as make a global-install variation
* linter for dependencies to check they all call process
* If you need to install dependencies inside a meet() block, fork to avoid clobbering
   the existing meet()
* Add a more complete logging function for dependencies to use
* More documentation
  * Usage information
  * How to write new helpers and built-ins and more complex dependencies
* `tests/` to use the [shunit2](https://github.com/kward/shunit2/) testing framework
*
