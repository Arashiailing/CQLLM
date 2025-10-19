import python

/**
 * @name CWE-287: Improper Authentication
 * @description Detects potential improper authentication issues by identifying scenarios where user credentials are not properly validated.
 */
from method m, call c
where 
    m.name = "authenticate" or 
    m.name = "login" or 
    m.name = "verify_credentials" or 
    m.name = "check_auth"
    and c.getTarget().getKind() = "FunctionCall"
    and (c.getArg(0).getType().isSubtypeOf("str") or c.getArg(0).getType().isSubtypeOf("bytes"))
    and not exists(
        from expr e
        where 
            e.isInstanceOf("ComparisonExpr") 
            and e.getLeftOperand().equals(c) 
            and e.getRightOperand().getType().isSubtypeOf("bool")
    )
select c, "Potential improper authentication: Credential validation missing or incomplete"