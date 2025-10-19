import python

/**
 * CWE-20: Improper Input Validation
 * This query detects potential instances of improper input validation in Python code.
 * It looks for functions that receive input and do not validate it properly.
 */

from Function f, Parameter param, Call call
where call.getCallee() = f and call.getArgument(0) = param
and not exists(Expr validation | validation instanceof IfExpr and validation.getCondition() instanceof BinaryExpr and validation.getCondition().getLeft() = param)
select f, "Function $f does not validate input parameter $param."