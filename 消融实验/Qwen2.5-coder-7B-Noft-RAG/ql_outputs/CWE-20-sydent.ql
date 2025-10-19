/**
* @name CWE-20: Improper Input Validation
*
@description The product receives input
    or data, but it does not validate
    or incorrectly validates that the input has the properties that are required to process the data safely
    and correctly.
*
@id py/sydent
*/
import python
import semmle.python.security.dataflow.InputValidationQuery
from DataFlow::CallCfgNode inputNode, DataFlow::Node validationNode
    where InputValidationQuery::flowPath(inputNode, validationNode)
    select validationNode.asExpr(), "Input validation is missing
    or incorrect."