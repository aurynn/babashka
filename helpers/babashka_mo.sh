## Taken from https://github.com/tests-always-included/mo/blob/master/demo/function-for-foreach
## under (what looks like) the MIT/BSD license.
babashka.mo.foreach() {
    # Trying to use unique names
    local foreachSourceName foreachIterator foreachEvalString foreachContent

    foreachContent=$(cat)

    local x
    x=("${@}")
    if [[ "$2" != "as" && "$2" != "in" ]]; then
        echo "Invalid foreach - bad format."
    elif [[ "$(declare -p "$1")" != "declare -"[aA]* ]]; then
        echo "$1 is not an array"
    else
        foreachSourceName="${1}[@]"

        for foreachIterator in "${!foreachSourceName}"; do
            foreachEvalString=$(declare -p "$foreachIterator")
            foreachEvalString="declare -A $3=${foreachEvalString#*=}"
            eval "$foreachEvalString"
            echo "$foreachContent" | mo
        done
    fi
}