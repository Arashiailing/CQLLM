import python

/**
 * A query to detect CWE-20: Improper Input Validation
 * in Python code.
 */

from Call call, StringLiteral literal
where call.getCallee().getName() = "open" and
      call.getArgument(0) = literal and
      not exists(Expr e |
        e instanceof Call and
        e.getCallee().getName() = "validate_path" and
        e.getArgument(0) = literal
      )
select call, "Improper input validation detected. The path is not validated before being used in the 'open' function."