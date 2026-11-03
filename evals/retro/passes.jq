# PASSES entries "<pass> -> applied: <change>" or "<pass> -> n/a: <fact>", up to the next report field.
# An empty change or fact is an unfilled entry: the capture requires a non-space first character. A change that starts
# with "<" is a template placeholder ("<change>"); later < and > are text (HTML tags, arrows) and count.
# Shared by evals/retro/index.sh and the written-report fallback of evals/score.sh (jq -L <this folder>).
def passes_of: (split("\n") | (map(test("^PASSES:")) | index(true)) as $i
  | if $i == null then [] else .[$i:] | (.[0] |= sub("^PASSES:\\s*";"")) | .[0:1] + (.[1:] | until(length==0 or (.[0]|test("^[A-Z]+:")); .[1:]) as $rest | .[0:(length - ($rest|length))]) end
  | map(capture("^\\s*(?<pass>[^<>|\\s][^<>|]*?)\\s*->\\s*(?<status>applied|n/a):\\s*(?<change>[^<|\\s][^|]*?)\\s*$")));
