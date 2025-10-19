import py

from Call call, StringLiteral sl
where call.getCallee() = "re.compile" or call.getCallee() = "re.match" or call.getCallee() = "re.search" or call.getCallee() = "re.sub" or call.getCallee() = "re.split"
and call.getArgument(0) = sl
and sl.getValue() matches /.*{,}|.*\*|.*\+|.*\?|.*\{.*\}.*\*|.*\{.*\}.*\+|.*\{.*\}.*\?|.*\(.+\)+/
select sl, "Potential CWE-400: Uncontrolled Resource Consumption via ReDoS in regex pattern."