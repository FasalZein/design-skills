# PASSES entries "<pass> -> applied: <change>" or "<pass> -> n/a: <fact>", up to the next report field.
# An empty change or fact is an unfilled entry: the capture requires a non-space first character. A change that starts
# with "<" is a template placeholder ("<change>"); later < and > are text (HTML tags, arrows) and count.
# A note in parentheses between the status and the colon keeps the status: "applied (+ fix): <change>" is applied
# (parent decision after owner decision 31: routing is scored apart from format). The output drops the note.
# Shared by evals/retro/index.sh and the written-report fallback of evals/score.sh (jq -L <this folder>).
def passes_of: (split("\n") | (map(test("^PASSES:")) | index(true)) as $i
  | if $i == null then [] else .[$i:] | (.[0] |= sub("^PASSES:\\s*";"")) | .[0:1] + (.[1:] | until(length==0 or (.[0]|test("^[A-Z]+:")); .[1:]) as $rest | .[0:(length - ($rest|length))]) end
  | map(capture("^\\s*(?<pass>[^<>|\\s][^<>|]*?)\\s*->\\s*(?<status>applied|n/a)(?:\\s*\\([^()|\\n]*\\))?:\\s*(?<change>[^<|\\s][^|]*?)\\s*$")));

# Report texts a session wrote, in call order (input: the session as one array, jq -s). A write tool call gives its
# content. A codemode call gives the content argument of each tools.write({..., content: X}) in its code: X is a string
# or template literal, or a name, read as the literal of the name's last assignment in that code. Template ${...}
# parts stay as text; any other X (a call, a concatenation) is not read. Only texts with RESULT and PASSES lines count.
# Used by the written-report fallback and the report item of evals/score.sh (owner decision 31).
def js_literal: "`(?<t>(?:[^`\\\\]|\\\\[\\s\\S])*)`|\"(?<d>(?:[^\"\\\\\\n]|\\\\.)*)\"|'(?<s>(?:[^'\\\\\\n]|\\\\.)*)'";
def js_text: (.t // .d // .s) | gsub("\\\\(?<c>[\\s\\S])"; if .c == "n" then "\n" elif .c == "t" then "\t" elif .c == "\n" then "" else .c end);
def codemode_writes: . as $code
  | capture("tools\\.write\\s*\\(\\s*\\{[^}]*?\\bcontent\\s*:\\s*(?:" + js_literal + "|(?<id>[A-Za-z_$][\\w$]*))"; "g")
  | if .id == null then js_text
    else (.id | gsub("\\$"; "\\$")) as $id | ([ $code | capture("(?:^|[^\\w$.])" + $id + "\\s*=\\s*(?:" + js_literal + ")"; "g") ] | last // empty | js_text) end;
# written_texts: every text written that way; written_reports: those with RESULT and PASSES lines.
def written_texts: [ .[] | select(.type=="message" and .message.role=="assistant") | .message.content[]? | select(.type=="toolCall")
  | if .name == "write" then (.arguments.content // "") elif .name == "codemode" then (.arguments.code // "" | codemode_writes) else empty end
  | strings ];
def written_reports: [ written_texts[] | select(test("(^|\n)RESULT:") and test("(^|\n)PASSES:")) ];
