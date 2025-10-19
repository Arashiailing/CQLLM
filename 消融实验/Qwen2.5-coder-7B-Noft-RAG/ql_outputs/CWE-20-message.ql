/**
* @name CWE-20: Improper Input Validation
*
@description The product receives input
    or data, but it does * not validate
    or incorrectly validates that the input has the * properties that are required to process the data safely
    and * correctly.
*
@id py/message
*/
import python
import semmle.python.security.dataflow.InsecureInputValidationQuery predicate insecure_input_validation(Call call) { exists(InsecureInputValidationQuery::InsecureInputValidationProblem problem | problem.getCall() = call ) }
from Call call
    where insecure_input_validation(call)
    select call, "Improper input validation detected."