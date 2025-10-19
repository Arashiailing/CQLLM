import python

/**
 * @predicate isDangerousFunctionCall(expr)
 * @description Checks if the expression represents a dangerous function call that could lead to code injection.
 */
predicate isDangerousFunctionCall(expr e) {
    // Check for direct calls to eval, exec, and __import__
    (e instanceof CallExpr
        and (callee.name = "eval" or callee.name = "exec" or callee.name = "__import__")
        and exists(ParamArg pa | pa.arg = e and pa.arg.isUserInput()))
}

/**
 * @query
 * @description Detects code injection vulnerabilities by identifying dangerous function calls with user inputs.
 */
from CallExpr ce
where isDangerousFunctionCall(ce)
select ce, "Potential code injection vulnerability: Dangerous function called with user input."