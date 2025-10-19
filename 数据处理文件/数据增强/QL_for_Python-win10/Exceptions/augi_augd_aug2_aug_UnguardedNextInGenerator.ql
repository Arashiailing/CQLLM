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
API::Node iterApiNode() { result = API::builtin("iter") }

// API node for built-in next() function
API::Node nextApiNode() { result = API::builtin("next") }

// API node for built-in StopIteration exception
API::Node stopIterationApiNode() { result = API::builtin("StopIteration") }

// Matches iter() calls with specific sequence argument
predicate iterCallWithSequence(CallNode iterCall, EssaVariable sequenceVariable) {
  iterCall = iterApiNode().getACall().asCfgNode() and
  iterCall.getArg(0) = sequenceVariable.getAUse()
}

// Checks if sequence has non-empty guard
predicate sequenceHasGuard(EssaVariable sequenceVariable) {
  sequenceVariable.getDefinition() instanceof EssaEdgeRefinement
}

/**
 * Holds if iterator is guaranteed to have remaining elements.
 * 
 * Common pattern: next(iter(x)) where x is known non-empty.
 */
predicate iteratorIsNonExhausted(EssaVariable iteratorVariable) {
  exists(EssaVariable sequenceVariable |
    iterCallWithSequence(iteratorVariable.getDefinition().(AssignmentDefinition).getValue(), sequenceVariable) and
    sequenceHasGuard(sequenceVariable)
  )
}

// Matches next() calls with specific iterator argument
predicate nextCallWithIterator(CallNode nextCall, ControlFlowNode iteratorArg) {
  nextCall = nextApiNode().getACall().asCfgNode() and
  nextCall.getArg(0) = iteratorArg
}

// Checks if next() call includes default value parameter
predicate nextCallHasDefault(CallNode nextCall) {
  exists(nextCall.getArg(1)) or exists(nextCall.getArgByName("default"))
}

// Checks if StopIteration exception is handled in current scope
predicate stopIterationIsHandled(CallNode nextCall) {
  exists(Try tryStmt |
    tryStmt.containsInScope(nextCall.getNode()) and
    tryStmt.getAHandler().getType() = stopIterationApiNode().getAValueReachableFromSource().asExpr()
  )
}

// Find unguarded next() calls in generators without default value or exception handling
from CallNode nextCall, ControlFlowNode iteratorArg
where
  // Verify next() call with iterator argument
  nextCallWithIterator(nextCall, iteratorArg) and
  // Ensure no default value provided
  not nextCallHasDefault(nextCall) and
  // Confirm iterator might be exhausted
  not exists(EssaVariable iteratorVariable |
    iteratorArg = iteratorVariable.getAUse() and
    iteratorIsNonExhausted(iteratorVariable)
  ) and
  // Restrict to generator functions
  nextCall.getNode().getScope().(Function).isGenerator() and
  // Exclude comprehensions
  not exists(Comp comp | comp.contains(nextCall.getNode())) and
  // Verify no StopIteration handling
  not stopIterationIsHandled(nextCall) and
  // PEP 479 resolves this in Python 3.7+
  // Only alert for Python 2 since minor version is unknown
  major_version() = 2
select nextCall, "Call to 'next()' in a generator."