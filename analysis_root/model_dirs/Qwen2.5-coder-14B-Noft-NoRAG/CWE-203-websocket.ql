import python

/**
 * CWE-203: Observable Discrepancy
 * Detects potential discrepancies between expected and actual behavior.
 */

from FunctionCall fc, Function f
where f.getName() = "websocket.send" and
      not exists(DataFlow::Expr df | df.getASink() = fc.getArgument(0))
select fc, "Potential observable discrepancy: Data sent over websocket may not be properly validated or sanitized."