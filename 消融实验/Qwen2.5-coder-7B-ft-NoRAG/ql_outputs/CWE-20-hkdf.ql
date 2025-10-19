/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 * not validate or incorrectly validates that the input has the
 * properties that are required to process the data safely and
 * correctly.
 * @id py/hkdf
 */
import python
import semmle.python.security.dataflow.InputValidationQuery

predicate improperInputValidation(InputValidationCheck check) {
  exists(InputValidationIssue issue | issue.getCheck() = check)
}

from InputValidationCheck check
where improperInputValidation(check)
select check, "Improper input validation detected."