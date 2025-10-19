import python

/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does not validate or incorrectly validates that the input has the properties that are required to process the data safely and correctly.
 * @id py/stringutils
 */

from InputCall input, Call call
where input.getCall() = call
  and call.getFunction().getName() = "input"
  and not (call.getArgument(0).getType().isSubtypeOf("str") or call.getArgument(0).getType().isSubtypeOf("int"))
select call, "Potential CWE-20: Improper Input Validation - Input not validated before use"