/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description Detection of sensitive information stored in cleartext files
 *              without proper encryption measures.
 * @kind problem
 * @problem.severity warning
 * @security-severity 9.1
 * @precision high
 * @id py/sosreport
 * @tags security
 *       external/cwe/cwe-200
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

// Predicate to identify file writing operations that store sensitive data
predicate hasSensitiveStore(string filename, string contentName, DataFlow::CallNode writeOperation) {
  exists(API::Call call |
    // Check for file writing operations performed through API calls
    call = writeOperation.(ApiCall).getAStaticMemberCall("write") and
    // Verify if the operation involves storing sensitive information
    call.isSinkForSensitiveData(filename, contentName)
  )
}

// Main query to detect cleartext storage of sensitive information
from DataFlow::CallNode writeOperation, string filename, string contentName
where
  // Ensure there is a data flow path from the content source to the write operation
  DataFlow::flowPath(ContentFlow::cflowNode(contentName), writeOperation) and
  // Confirm that the write operation stores sensitive data
  hasSensitiveStore(filename, contentName, writeOperation)
select writeOperation,
  // Generate warning message highlighting the issue
  "Writing '" + contentName + "' to file '$@' may expose this information to unauthorized access.", filename,
  "sensitive information"