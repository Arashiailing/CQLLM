/**
 * @name Weak Sensitive Data Hashing
 * @description Using a weak hashing algorithm for sensitive data can lead to vulnerabilities.
 * @id py/weak-sensitive-data-hashing
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.0
 * @precision high
 * @tags security
 *       external/cwe/cwe-331
 */

import python
import experimental.semmle.python.security.WeakHashing

from Function f, StringLiteral sl
where
  f.getName() = "hash" and
  f.getParameters()[0].getType().isAssignableFrom(sl.getType()) and
  not WeakHashing.isStrongHashAlgorithm(sl)
select f, "Weak hashing algorithm used for sensitive data."