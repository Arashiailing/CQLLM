/**
* @name CWE-20: Improper Input Validation
*
@description The product receives input
    or data, but it does * not validate
    or incorrectly validates that the input has the * properties that are required to process the data safely
    and * correctly.
*
@id py/security-groups
*/
import python
import semmle.python.security.dataflow.InsecureInputValidationQuery predicate insecure_input_validation(Input input) { exists(PathNode source, PathNode sink | InsecureInputValidationFlow::flowPath(source, sink)
    and source.getNode() = input
    and sink.getNode().isSink() ) }
from Input input
    where insecure_input_validation(input)
    select input, "Insecure input validation detected."