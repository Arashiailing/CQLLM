import semmle.python.Python

from CallExpr c
where c.getKind() = "Call" and c.getFunctionName() = "str" and c.getArgument(0).getType().getName() = "str"
select c, "Potential reflected XSS due to direct user input usage."