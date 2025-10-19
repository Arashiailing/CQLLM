/**
* @name Weak Sensitive Data Hashing
*
@description Using a weak hash function f
    or sensitive data can compromise security.
* @kind problem
*
@id py/weak-sensitive-data-hashing
* @problem.severity error
* @security-severity 9.0
* @precision high
*
@tags security * external/cwe/cwe-331
*/
import python
import experimental.semmle.python.security.Hashing predicate isWeakHashFunction(Call call) { exists(API::Node func | func.getACall().asExpr() = call
    and func.getName() in {"md5", "sha1"}) }
from Call call
    where isWeakHashFunction(call)
    select call, "Using a weak hash function f
    or sensitive data."