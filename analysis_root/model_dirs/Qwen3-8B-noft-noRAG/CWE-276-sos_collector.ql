import python

/** @name CWE-276: Incorrect Default Permissions */
/** @description Detects incorrect default permissions in Python code by checking calls to os.chmod with insecure permission modes */

from Call call, IntegerLiteral modeLit
where 
    call.getCallee().getName() = "chmod" and 
    call.getModule().getName() = "os" and 
    modeLit.getValue() > 0o666 and 
    modeLit.getValue() < 0o700 or 
    modeLit.getValue() == 0o644 or 
    modeLit.getValue() == 0o666
select call, "Potential insecure permission mode detected: " + modeLit.getValue().toString() + ". Consider using more restrictive settings like 0o600 for sensitive files."