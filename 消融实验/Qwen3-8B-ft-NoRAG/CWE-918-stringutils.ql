import python

from Call call, StringLiteral url
where call.getCallee().getName() = "get"
  and call.getImportedModule().getName() = "requests"
  and call.getArgument(0) = url
select url, "Potential SSRF vulnerability: URL is directly taken from user input."