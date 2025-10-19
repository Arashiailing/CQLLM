import python

/**
 * This query detects CWE-20: Improper Input Validation.
 * It looks for functions that receive input but do not validate it properly.
 */

from Function func, Parameter param
where func.hasBody() and param.getDeclaringFunction() = func
  and not exists(InputValidation validation | validation.getFunction() = func and validation.getParameter() = param)
select func, param, "Function does not validate input parameter."