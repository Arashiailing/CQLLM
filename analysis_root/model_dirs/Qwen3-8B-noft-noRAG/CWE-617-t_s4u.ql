import python

/**
 * @name CWE-617: Command Injection
 * @description Detects command injection vulnerabilities by identifying dangerous function calls with untrusted input.
 */
from Call call, StringLiteral arg
where 
    (call.getSelector().getName() = "call" or 
     call.getSelector().getName() = "run" or 
     call.getSelector().getName() = "exec" or 
     call.getSelector().getName() = "Popen") 
    and call.getArg(0) = arg
    and arg.getValue().contains("'$'")
select call, "Potential command injection vulnerability: dangerous function called with unquoted string argument."