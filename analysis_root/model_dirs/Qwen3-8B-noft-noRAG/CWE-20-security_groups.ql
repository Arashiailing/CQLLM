import python

/** @predicate */
def is_input_validation_failure(callee: Function, call: Call): bool {
    // Check for common input sources like input(), sys.stdin, etc.
    if (callee.name == "input" or callee.name == "sys.stdin.read") {
        // Look for lack of validation after input
        let value = call.getArgument(0)
        // Check for missing length checks
        exists (expr: Expr) | 
            expr.isCallTo("len") and 
            expr.getArgument(0).isEqual(value) and 
            not expr.isInCondition()
        
        // Check for missing type conversion with validation
        exists (expr: Expr) | 
            expr.isCallTo("int") or expr.isCallTo("float") or 
            expr.isCallTo("str") and 
            not expr.isInCondition()
        
        // Check for missing range checks on numeric inputs
        exists (expr: Expr) | 
            expr.isBinaryOp("in") or expr.isBinaryOp("between") and 
            expr.getRightOperand().isLiteralInt() and 
            expr.getLeftOperand().isEqual(value) and 
            not expr.isInCondition()
        
        return true
    }
    false
}

from Call call
where is_input_validation_failure(call.getCallee(), call)
select call.getLocation(), "Potential CWE-20: Improper Input Validation detected"