import python

/**
 * Detects CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * in Python code.
 */
from Call call, Argument arg, StringLiteral strLit
where call.getCallee().getName() = "open"
  and call.getArgument(0) = arg
  and arg.getExpr() = strLit
select call, "Potentially vulnerable to CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer"