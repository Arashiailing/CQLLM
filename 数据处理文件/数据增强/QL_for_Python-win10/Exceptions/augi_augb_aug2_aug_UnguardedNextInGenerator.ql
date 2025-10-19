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

// API node for built-in iter() function
API::Node builtinIter() { result = API::builtin("iter") }

// API node for built-in next() function
API::Node builtinNext() { result = API::builtin("next") }

// API node for built-in StopIteration exception
API::Node builtinStopIteration() { result = API::builtin("StopIteration") }

// Identifies iter() calls with specified sequence argument
predicate iterCallOnSequence(CallNode iterCall, EssaVariable sequenceVar) {
  iterCall = builtinIter().getACall().asCfgNode() and
  iterCall.getArg(0) = sequenceVar.getAUse()
}

// Identifies next() calls with specified iterator argument
predicate nextCallOnIterator(CallNode nextCall, ControlFlowNode iteratorNode) {
  nextCall = builtinNext().getACall().asCfgNode() and
  nextCall.getArg(0) = iteratorNode
}

// Checks if next() call provides a default value
predicate nextCallWithDefault(CallNode nextCall) {
  exists(nextCall.getArg(1)) or exists(nextCall.getArgByName("default"))
}

/**
 * Holds if iterator is guaranteed non-exhausted.
 * 
 * Common pattern: next(iter(x)) where x is known non-empty.
 */
predicate isNonExhaustedIterator(EssaVariable iteratorVar) {
  exists(EssaVariable sequenceVar |
    iterCallOnSequence(iteratorVar.getDefinition().(AssignmentDefinition).getValue(), sequenceVar) and
    sequenceVar.getDefinition() instanceof EssaEdgeRefinement
  )
}

// Checks if StopIteration exception is handled in scope
predicate isStopIterationHandled(CallNode nextCall) {
  exists(Try tryStmt |
    tryStmt.containsInScope(nextCall.getNode()) and
    tryStmt.getAHandler().getType() = builtinStopIteration().getAValueReachableFromSource().asExpr()
  )
}

// Find unguarded next() calls in generators without default value or exception handling
from CallNode nextCall, ControlFlowNode iteratorNode
where
  // Verify next() call with iterator argument
  nextCallOnIterator(nextCall, iteratorNode) and
  // Ensure no default value provided
  not nextCallWithDefault(nextCall) and
  // Confirm iterator might be exhausted
  not exists(EssaVariable iteratorVar |
    iteratorNode = iteratorVar.getAUse() and
    isNonExhaustedIterator(iteratorVar)
  ) and
  // Restrict to generator functions
  nextCall.getNode().getScope().(Function).isGenerator() and
  // Exclude comprehensions
  not exists(Comp comp | comp.contains(nextCall.getNode())) and
  // Verify no StopIteration handling
  not isStopIterationHandled(nextCall) and
  // PEP 479 resolves this in Python 3.7+
  // Only alert for Python 2 since minor version is unknown
  major_version() = 2
select nextCall, "Call to 'next()' in a generator."