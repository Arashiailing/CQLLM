import python

from Call, StringConcatenate
where Call.getMethod(Call) = "get"
  and Call.getTarget(Call) = "request"
  and StringConcatenate.hasOperandOfType(StringConcatenate, "str")
  and StringConcatenate.getParent().getKind() = "ReturnStmt"
select StringConcatenate, "Potential reflected XSS: User input is directly concatenated into HTML output."