import python
import semmle.code.cpp.callgraph.CallGraph
import semmle.code.cpp.querying.Conversions

from Method m, Call c
where 
  (c.getTarget().getSymbol().getName() = "md5" or 
   c.getTarget().getSymbol().getName() = "sha1" or 
   c.getTarget().getSymbol().getName() = "sha") and
  c.getModule().getName() = "hashlib"
select c, "Potential use of weak hashing algorithm for sensitive data."