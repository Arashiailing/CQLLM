import python

/**
 * CWE-20: Improper Input Validation
 * This query detects potential instances of CWE-20 by looking for
 * functions that receive input but do not validate it properly.
 */

from Function func, Parameter param
where func.getAParameter() = param and not exists(InputValidation validation | validation.getFunction() = func and validation.getParameter() = param)
select func, "Function $func does not validate input parameter $param properly."