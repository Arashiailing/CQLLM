import python

from CallExpr ce, StringLiteral sl
where ce.getOperator() = "%" and ce.getArg(0) = sl
select ce, "Potential LogInjection via unescaped user input in string formatting"