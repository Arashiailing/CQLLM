/**
 * @name Unguarded next in generator
 * @description Detects next() calls in generators lacking proper guarding, potentially causing unintended iteration termination.
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

// Built-in function references
API::Node iterFunction() { result = API::builtin("iter") }

API::Node nextFunction() { result = API::builtin("next") }

API::Node stopIterationException() { result = API::builtin("StopIteration") }

// Identify iter() calls with specific sequence argument
predicate iterCallWithSequence(CallNode iterCall, EssaVariable seqVar) {
  iterCall = iterFunction().getACall().asCfgNode() and
  iterCall.getArg(0) = seqVar.getAUse()
}

// Identify next() calls with iterator argument
predicate nextCallWithIterator(CallNode nextCall, ControlFlowNode iterArg) {
  nextCall = nextFunction().getACall().asCfgNode() and
  nextCall.getArg(0) = iterArg
}

// Check if next() call provides default value
predicate nextCallProvidesDefault(CallNode nextCall) {
  exists(nextCall.getArg(1)) or exists(nextCall.getArgByName("default"))
}

// Verify sequence is guarded and non-empty
predicate sequenceIsGuarded(EssaVariable seqVar) {
  seqVar.getDefinition() instanceof EssaEdgeRefinement
}

/**
 * Holds if iterator is guaranteed non-exhausted.
 * 
 * Common pattern: next(iter(x)) where x is known non-empty.
 */
predicate iteratorIsNonExhausted(EssaVariable iterVar) {
  exists(EssaVariable seqVar |
    iterCallWithSequence(iterVar.getDefinition().(AssignmentDefinition).getValue(), seqVar) and
    sequenceIsGuarded(seqVar)
  )
}

// Check if StopIteration exception is handled in scope
predicate stopIterationIsHandled(CallNode nextCall) {
  exists(Try tryStmt |
    tryStmt.containsInScope(nextCall.getNode()) and
    tryStmt.getAHandler().getType() = stopIterationException().getAValueReachableFromSource().asExpr()
  )
}

// Find unguarded next() calls in generators without default value or exception handling
from CallNode nextCall, ControlFlowNode iterArg
where
  // Verify next() call with iterator argument
  nextCallWithIterator(nextCall, iterArg) and
  // Ensure no default value provided
  not nextCallProvidesDefault(nextCall) and
  // Confirm iterator might be exhausted
  not exists(EssaVariable iterVar |
    iterArg = iterVar.getAUse() and
    iteratorIsNonExhausted(iterVar)
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