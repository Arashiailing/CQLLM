/**
 * @name Unguarded next in generator
 * @description Detects unguarded next() calls in generators that may cause unintended iteration termination.
 * @kind problem
 * @tags maintainability
 *       portability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/unguarded-next-in-generator
 */

import python
private import semmle.python.ApiGraphs

// API nodes for built-in functions and exceptions
API::Node builtinIterFunction() { result = API::builtin("iter") }
API::Node builtinNextFunction() { result = API::builtin("next") }
API::Node builtinStopIterationException() { result = API::builtin("StopIteration") }

// Identifies iter() calls with specified sequence argument
predicate iterCallWithSequence(CallNode iterCallNode, EssaVariable sequenceVar) {
  iterCallNode = builtinIterFunction().getACall().asCfgNode() and
  iterCallNode.getArg(0) = sequenceVar.getAUse()
}

// Identifies next() calls with specified iterator argument
predicate nextCallWithIterator(CallNode nextCallNode, ControlFlowNode iteratorNode) {
  nextCallNode = builtinNextFunction().getACall().asCfgNode() and
  nextCallNode.getArg(0) = iteratorNode
}

// Checks if next() call provides a default value
predicate nextCallHasDefault(CallNode nextCallNode) {
  exists(nextCallNode.getArg(1)) or exists(nextCallNode.getArgByName("default"))
}

// Checks if sequence is guarded and non-empty
predicate isSequenceGuarded(EssaVariable sequenceVar) {
  sequenceVar.getDefinition() instanceof EssaEdgeRefinement
}

/**
 * Holds if iterator is guaranteed non-exhausted.
 * Common pattern: next(iter(x)) where x is known non-empty.
 */
predicate isIteratorNonExhausted(EssaVariable iteratorVar) {
  exists(EssaVariable sequenceVar |
    iterCallWithSequence(iteratorVar.getDefinition().(AssignmentDefinition).getValue(), sequenceVar) and
    isSequenceGuarded(sequenceVar)
  )
}

// Checks if StopIteration exception is handled in scope
predicate isStopIterationCaught(CallNode nextCallNode) {
  exists(Try tryStmt |
    tryStmt.containsInScope(nextCallNode.getNode()) and
    tryStmt.getAHandler().getType() = builtinStopIterationException().getAValueReachableFromSource().asExpr()
  )
}

// Find unguarded next() calls in generators without default value or exception handling
from CallNode nextCallNode, ControlFlowNode iteratorNode
where
  // Verify next() call with iterator argument
  nextCallWithIterator(nextCallNode, iteratorNode) and
  // Ensure no default value provided
  not nextCallHasDefault(nextCallNode) and
  // Confirm iterator might be exhausted
  not exists(EssaVariable iteratorVar |
    iteratorNode = iteratorVar.getAUse() and
    isIteratorNonExhausted(iteratorVar)
  ) and
  // Restrict to generator functions
  nextCallNode.getNode().getScope().(Function).isGenerator() and
  // Exclude comprehensions
  not exists(Comp comprehension | comprehension.contains(nextCallNode.getNode())) and
  // Verify no StopIteration handling
  not isStopIterationCaught(nextCallNode) and
  // PEP 479 resolves this in Python 3.7+
  // Only alert for Python 2 since minor version is unknown
  major_version() = 2
select nextCallNode, "Call to 'next()' in a generator."