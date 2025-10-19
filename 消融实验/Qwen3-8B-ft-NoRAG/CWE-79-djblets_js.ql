import python

from Call call, StringLiteral str
where call.getCallee().getName() = "print"
  and call.getArgument(0).getType().isString()
  and str.getValue() = call.getArgument(0).getValue()
  and str.getValue().contains("{{") or str.getValue().contains("<") or str.getValue().contains(">")
select call, "Potential Reflected XSS vulnerability due to direct user input in HTML output."