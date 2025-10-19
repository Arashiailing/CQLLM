/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind problem
 * @problem.severity warning
 * @security-severity 6.1
 * @precision high
 * @id py/stringutils
 * @tags correctness
 *       security
 *       external/cwe/cwe-20
 */

import python
import semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

predicate untrustedInput(StringLiteral strLit) {
  strLit.isUntrustedSource()
}

// Check if there's a direct connection between untrusted input and a dangerous operation
predicate directConnectionExists(StringLiteral untrustedInput, StringLiteral dangerousString) {
  exists(Call call |
    call = dangerousString.getACall() and
    call.getFunc().fullyQualifiedName() in ["string.capwords", "str.capitalize"] and
    call.getParameter(0) = untrustedInput
  )
}

// Detect unsafe operations performed on potentially untrusted data
predicate unsafeOperationOnUntrustedData(StringLiteral untrustedInput, StringLiteral dangerousString) {
  directConnectionExists(untrustedInput, dangerousString)
}

// Main query: Find instances where untrusted data is processed without proper validation
from StringLiteral untrustedInput, StringLiteral dangerousString
where unsafeOperationOnUntrustedData(untrustedInput, dangerousString)
select dangerousString,
  "This string operation uses $@ without verifying its content.", untrustedInput,
  "untrusted input"