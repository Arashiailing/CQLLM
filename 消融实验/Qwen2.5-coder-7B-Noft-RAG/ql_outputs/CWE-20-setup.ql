/**
* @name CWE-20: Improper Input Validation
*
@description The product receives input
    or data, but it does * not validate
    or incorrectly validates that the input has the * properties that are required to process the data safely
    and * correctly.
*
@id py/setup
*/
import python
import semmle.python.security.dataflow.InsecureInputValidationQuery
from InsecureInputValidationFlow::PathNode source, InsecureInputValidationFlow::PathNode sink
    where InsecureInputValidationFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Input validation issue detected."