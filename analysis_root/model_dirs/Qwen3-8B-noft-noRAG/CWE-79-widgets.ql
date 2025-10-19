import python

from PrintStmt ps, StringLiteral sl, CallExpr ce
where ps.getArgs().has(ce)
  and ce.getCallee().getName() = "format"
  and sl.getValue().contains("{{")
select ps, "Potential reflected XSS: User input is directly embedded in HTML output without proper escaping."