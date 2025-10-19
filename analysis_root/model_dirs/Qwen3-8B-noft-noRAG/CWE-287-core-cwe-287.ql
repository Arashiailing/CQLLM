import python

/**
 * @name CWE-287: Improper Authentication
 * @description Detects improper authentication by identifying missing password verification in authentication flows.
 */
from method m, call c
where 
    m.name = "authenticate" or m.name = "login" or m.name = "validate_user"
    and c.getTarget() = m
    and not (c.getArg(0).getType().getName() = "str" and c.getArg(1).getType().getName() = "str")
select c, "Potential improper authentication: Missing password verification in authentication flow."