/**
 * @name CWE-310: Weak Sensitive Data Hashing
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.0
 * @precision high
 * @id py/pycrypto
 */

import python
import experimental.cryptography.Concepts

from HashAlgorithm alg, String data
where
  alg.isWeak() and
  alg.hash(data)
select alg, data, "Weak hashing algorithm used for sensitive data"