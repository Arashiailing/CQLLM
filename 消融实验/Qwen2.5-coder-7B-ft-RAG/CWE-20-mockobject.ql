/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @id py/mockobject
 * @tags correctness
 *       security
 *       external/cwe/cwe-20
 */

import python
import MockObjectDetection
private import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

// Predicate to identify calls to unsafe mock methods
predicate unsafeMockCall(CallNode call, ApiNode apiNode) {
  apiNode.getKind() = "call" and
  call = apiNode.getACall()
}

// Main query to detect unsafe mock objects
from DataFlow::CallCfgNode mockCall, DataFlow::Node argNode, ApiNode apiNode
where
  unsafeMockCall(mockCall, apiNode) and
  // Check if the argument is directly from the mock call
  argNode = mockCall.getArg(0) and
  // Verify if the argument is a valid mock object
  exists(MockObject mo | mo.isReference(argNode) |
    mo.hasDangerousMethods()
  )
select mockCall.asExpr(), "Argument to $@() could be a dangerous mock object.", apiNode,
  "mockobject"