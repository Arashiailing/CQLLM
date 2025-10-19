/**
 * @name CWE-310: Weak Sensitive Data Hashing
 * @description Using weak cryptographic hash functions for sensitive data hashing may compromise security.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/cwe-310
 * @tags security
 */

import python
import experimental.cryptography.Concepts

from HashAlgorithm alg
where alg.isWeak()
select alg, "Use of weak cryptographic hash function " + alg.getName() + " for sensitive data"