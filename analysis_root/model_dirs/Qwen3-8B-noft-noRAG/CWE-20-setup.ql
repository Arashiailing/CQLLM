import python

/** @predicate */
def isInputFunction(call: Call): bool {
    return call.getMethod().getName() in ["input", "raw_input"]
}

/** @predicate */
def isUnsafeUsage(expr: Expression): bool {
    // Check for direct use in dangerous contexts like eval, exec, etc.
    if (expr instanceof Call) {
        let c = expr.as(Call)
        return c.getMethod().getName() in ["eval", "exec", "getattr", "setattr", "delattr"] or
               c.getMethod().getName() = "open" and c.getArg(0).toString() is NotNull
    }
    return false
}

from Call c
where isInputFunction(c)
let inputVal = c.getArg(0)
filter (inputVal is NotNull)
let nextStmt = c.getNextStatement()
where nextStmt is Assignment
let assignedVar = nextStmt.getAssignee()
from Use u where u.getExpression() = assignedVar
filter isUnsafeUsage(u)
select c, "Potential CWE-20: Unvalidated input used in unsafe context", c.getLocation()