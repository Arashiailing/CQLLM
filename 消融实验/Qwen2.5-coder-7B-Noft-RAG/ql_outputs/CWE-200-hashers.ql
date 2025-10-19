/**
* @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
*
@description Exposure of sensitive information to an unauthorized act
    or due to weak hashing algorithms.
* @kind path-problem
* @problem.severity warning
* @precision high
* @security-severity 6.5
*
@id py/hashers
*/
import python
import semmle.python.security.hashing.WeakHashing
from HashFunction hashFunc
    where WeakHashing::isWeak(hashFunc)
    select hashFunc, "The hashing algorithm used is weak
    and exposes sensitive information."