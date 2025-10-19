/**
 * @name CWE-255: Weak Sensitive Data Hashing
 * @description Weak hashing algorithms should not be used for sensitive data.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision high
 * @id py/weak-sensitive-data-hashing
 * @tags security
 */

import python
import semmle.python.security.dataflow.SensitiveDataHashingQuery

from SensitiveDataHashingQuery::PathNode source, SensitiveDataHashingQuery::PathNode sink
where SensitiveDataHashingQuery::flowPath(source, sink)
select sink.getNode(), source, sink, "Weak hashing algorithm detected for sensitive data."