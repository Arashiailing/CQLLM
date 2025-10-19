import python

/**
 * CWE-20: Improper Input Validation
 * This query detects potential improper input validation in Python code.
 */

from Call call, Function func
where func.getName() = "matrix_federation_agent"
  and call.getCallee() = func
  and not exists(InputValidation validation | validation.getValidationCall() = call)
select call, "This call to matrix_federation_agent may not validate input properly."