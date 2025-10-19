python
import python
import semmle.python.security.dataflow.PolynomialReDoSQuery
import PolynomialReDoSFlow::PathGraph
from Loop loop, PathNode source, PathNode sink
    where PolynomialReDoSFlow::flowPath(source, sink)
    and loop.hasExitCondition()
    and not exists(ControlFlowEdge edge | edge.getSource() = loop.getExitCondition())
    select loop, "The loop has an unreachable exit condition, which may lead to an infinite loop."