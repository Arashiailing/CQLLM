/**
 * @name CWE-310: Weak Sensitive Data Hashing
 * @kind problem
 * @id py/CWE-310
 * @problem.severity warning
 * @security-severity 8.2
 * @precision high
 * @tags security
 */

import python
import experimental.cryptography.Hashing

from HashFunction hashFunc
where hashFunc.isSHA1()
select hashFunc, "Use of SHA-1 for hashing sensitive data is insecure."