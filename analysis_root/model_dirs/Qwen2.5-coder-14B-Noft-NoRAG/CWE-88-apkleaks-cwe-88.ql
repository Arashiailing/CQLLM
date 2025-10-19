import python

/**
 * CWE-88: Improper Neutralization of Argument Delimiters in a Command ('Argument Injection')
 */
from CallExpr call, Arg arg
where call.getCallee().getName() = "subprocess.Popen" and
      arg instanceof StringLiteral
select arg, "Potentially vulnerable to CWE-88: Improper Neutralization of Argument Delimiters in a Command ('Argument Injection')."