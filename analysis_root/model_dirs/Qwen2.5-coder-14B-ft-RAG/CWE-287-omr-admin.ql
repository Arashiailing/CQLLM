/**
 * @name Cleartext storage of sensitive information
 * @description Storing passwords in cleartext may expose them to unauthorized users.
 * @kind problem
 * @tags security
 *       external/cwe/cwe-312
 * @problem.severity error
 * @security-severity 7.5
 * @sub-severity high
 * @precision medium
 * @id py/clear-text-storage
 */

import python
import semmle.python.dataflow.new.DataFlow
import FluentApiConcepts

// Helper predicate to determine if a node is part of a hashing operation
predicate hashingOperation(Node hashNode, string algorithmName) {
  exists(HashAlgorithm hashAlg |
    hashAlg = hashNode.(CallNode).getFunc().(AttrNode).getObject() and
    algorithmName = hashAlg.getName()
  )
}

// Helper predicate to determine if a node represents sensitive data storage
predicate storesSensitiveData(Node storeNode, string dataType) {
  exists(StoreAction storeAction |
    storeAction = storeNode.(CallNode).getFunc().(AttrNode).getObject() and
    dataType = storeAction.getType()
  )
}

// Main query to detect cleartext storage vulnerabilities
from Node storeNode, string dataType
where
  // Check if the node stores sensitive data and ensure there is no hashing operation involved
  storesSensitiveData(storeNode, dataType) and
  not exists(Node hashNode | hashingOperation(hashNode, _) and dataFlow::flowPath(hashNode, storeNode))
select storeNode,
  "A " + dataType + " is stored without proper cryptographic transformation."