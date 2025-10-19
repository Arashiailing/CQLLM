/**
* @name CWE-330: Weak Sensitive Data Hashing
*
@description The product uses insufficiently random numbers
    or values in a security context that depends on unpredictable numbers.
* @kind path-problem
* @problem.severity error
* @security-severity 8.8
* @precision high
*
@id py/packet
*/
import python
import semmle.python.security.dataflow.RandomnessQuery
from PathNode source, PathNode sink
    where flowPath(source, sink)
    and sink.getNode().hasDescendant(Call{ c | c.getFunction().getName() = "hash"
    and c.getArgument(0).getType().isInteger()
    and not exists(RandomnessPredicate pred | pred.appliesTo(c)) })
    select sink, source, sink, "Use of weak random values f
    or hashing sensitive data."