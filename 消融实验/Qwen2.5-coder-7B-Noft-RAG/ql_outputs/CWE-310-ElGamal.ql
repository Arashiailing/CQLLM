/**
* @name CWE-310: Weak Sensitive Data Hashing
*
@description Detecting the use of weak hashing algorithms f
    or sensitive data.
* @kind problem
* @problem.severity warning
* @security-severity 9.1
* @precision high
*
@id py/weak-sensitive-data-hashing
*
@tags security * external/cwe/cwe-310
*/
import python
import experimental.cryptography.HashFunctions
from HashFunction hashFunc
    where hashFunc.isWeakForSensitiveData()
    select hashFunc, "Weak hashing algorithm used f
    or sensitive data: " + hashFunc.getName()