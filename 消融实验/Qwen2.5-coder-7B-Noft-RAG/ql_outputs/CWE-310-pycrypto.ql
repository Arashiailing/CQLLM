/**
* @name CWE-310: Weak Sensitive Data Hashing
*
@description Hashing sensitive data using weak
    or insecure algorithms can expose users to security risks.
* @kind path-problem
* @problem.severity error
* @security-severity 7.8
* @precision high
*
@id py/pycrypto
*/
import python
import experimental.cryptography.HashFunctions
from HashFunction hashFunc
    where hashFunc.isWeak()
    select hashFunc, "Weak hashing function detected: " + hashFunc.getName()