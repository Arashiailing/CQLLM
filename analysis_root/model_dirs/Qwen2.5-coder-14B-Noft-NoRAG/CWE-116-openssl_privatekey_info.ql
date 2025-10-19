import python

/**
 * This query detects potential CWE-116: Path Injection vulnerabilities
 * by looking for instances where user input is directly used to construct
 * file paths without proper validation or sanitization.
 */

from StringLiteral path, Call call
where call.getCallee().getName() = "open" and
      call.getArgument(0) = path and
      not exists(Expr e |
        e instanceof BinaryExpr and
        e.getOperator() = "+" and
        e.getLeftOperand() = path and
        e.getRightOperand() instanceof FunctionCall and
        e.getRightOperand().getCallee().getName() = "sanitize_path"
      )
select call, "This call to 'open' uses a string literal directly to construct a file path without sanitization."