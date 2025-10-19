/**
 * @name Unguarded next in generator
 * @description Detects generator functions where next() is called without proper exhaustion checks.
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
API::Node iterBuiltin() { result = API::builtin("iter") }
API::Node nextBuiltin() { result = API::builtin("next") }
API::Node stopIterationBuiltin() { result = API::builtin("StopIteration") }

// Identifies iter() calls with specific sequence source
predicate iterCallWithSequenceSource(CallNode iterCall, EssaVariable originalSequence) {
  iterCall = iterBuiltin().getACall().asCfgNode() and
  iterCall.getArg(0) = originalSequence.getAUse()
}

// Identifies next() calls targeting specific iterator
predicate nextCallOnIteratorVar(CallNode nextCallNode, ControlFlowNode iteratorVar) {
  nextCallNode = nextBuiltin().getACall().asCfgNode() and
  nextCallNode.getArg(0) = iteratorVar
}

// Checks if next() call includes default value parameter
predicate nextCallWithDefault(CallNode nextCallNode) {
  exists(nextCallNode.getArg(1)) or exists(nextCallNode.getArgByName("default"))
}

// Determines if sequence has emptiness protection
predicate sequenceIsGuarded(EssaVariable seqVar) {
  seqVar.getDefinition() instanceof EssaEdgeRefinement
}

/**
 * Holds when iterator is verified non-exhausted.
 * 
 * Detects patterns like next(iter(x)) where x is confirmed non-empty.
 */
predicate iteratorIsNonExhausted(EssaVariable iterVar) {
  exists(EssaVariable originalSequence |
    iterCallWithSequenceSource(iterVar.getDefinition().(AssignmentDefinition).getValue(), originalSequence) and
    sequenceIsGuarded(originalSequence)
  )
}

// Verifies StopIteration exception handling in current scope
predicate stopIterationIsHandled(CallNode nextCallNode) {
  exists(Try tryStmt |
    tryStmt.containsInScope(nextCallNode.getNode()) and
    tryStmt.getAHandler().getType() = stopIterationBuiltin().getAValueReachableFromSource().asExpr()
  )
}

// Main query detecting unguarded next() calls in generators
from CallNode nextCall
where
  // Validate next() function call
  nextCallOnIteratorVar(nextCall, _) and
  // Ensure no default value protection
  not nextCallWithDefault(nextCall) and
  // Confirm iterator might be exhausted
  not exists(EssaVariable iterVar |
    nextCallOnIteratorVar(nextCall, iterVar.getAUse()) and
    iteratorIsNonExhausted(iterVar)
  ) and
  // Restrict to generator functions
  nextCall.getNode().getScope().(Function).isGenerator() and
  // Exclude comprehensions
  not exists(Comp comprehension | comprehension.contains(nextCall.getNode())) and
  // Verify no StopIteration handling
  not stopIterationIsHandled(nextCall) and
  // PEP 479 resolved this issue in Python 3.7+
  // Flag only for Python 2 (minor version not detectable)
  major_version() = 2
select nextCall, "Call to 'next()' in a generator."