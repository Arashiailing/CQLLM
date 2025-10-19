import python

/**
 * @name LogInjectionQuery
 * @description Detects potential log injection vulnerabilities by identifying direct usage of untrusted inputs in logging statements.
 */
from LoggerCall call, StringLiteral msgLit, Variable var
where 
    call.getFunction().getName() = "info" or 
    call.getFunction().getName() = "warning" or 
    call.getFunction().getName() = "error" or 
    call.getFunction().getName() = "debug"
    and call.getArg(0).getValue().toString() = msgLit.getValue()
    and exists (var, ConcatExpr concat |
        concat.getParent() = call.getArg(0) and
        concat.hasOperand(var) and
        not var.getType().isPrimitive())
select call.getLocation(), "Potential log injection vulnerability detected: Untrusted input directly concatenated into log message."