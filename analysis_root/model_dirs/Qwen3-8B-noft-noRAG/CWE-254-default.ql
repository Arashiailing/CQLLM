import python

from CallExpr call, Module m
where 
    m.getName() = "pam"
    and call.getMethodName() = "authorize"
    or call.getMethodName() = "check_credentials"
    or call.getMethodName() = "validate"
select call, "Potential CWE-254: Insecure authorization mechanism detected via PAM-related function call."