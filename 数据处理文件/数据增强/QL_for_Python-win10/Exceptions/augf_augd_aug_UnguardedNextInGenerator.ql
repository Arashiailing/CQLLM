/**
 * @name Unguarded next in generator
 * @description Identifies unguarded next() calls in generators that may cause unintended iteration termination.
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

// Identifies iter() calls with specific sequence argument
predicate iterCallWithSequence(CallNode iterInvocation, EssaVariable sequenceVar) {
  iterInvocation = iterFunction().getACall().asCfgNode() and
  iterInvocation.getArg(0) = sequenceVar.getAUse()
}

// Identifies next() calls with iterator argument
predicate nextCallWithIterator(CallNode nextInvocation, ControlFlowNode iteratorArgument) {
  nextInvocation = nextFunction().getACall().asCfgNode() and
  nextInvocation.getArg(0) = iteratorArgument
}

// Checks if next() call provides default value
predicate nextCallProvidesDefault(CallNode nextInvocation) {
  exists(nextInvocation.getArg(1)) or exists(nextInvocation.getArgByName("default"))
}

// Verifies sequence is guarded and non-empty
predicate sequenceIsGuarded(EssaVariable sequenceVar) {
  sequenceVar.getDefinition() instanceof EssaEdgeRefinement
}

/**
 * Holds if iterator is guaranteed non-exhausted.
 * 
 * Common pattern: next(iter(x)) where x is known non-empty.
 */
predicate iteratorIsNonExhausted(EssaVariable iteratorVar) {
  exists(EssaVariable sequenceVar |
    iterCallWithSequence(iteratorVar.getDefinition().(AssignmentDefinition).getValue(), sequenceVar) and
    sequenceIsGuarded(sequenceVar)
  )
}

// Checks if StopIteration exception is handled in scope
predicate stopIterationIsHandled(CallNode nextInvocation) {
  exists(Try tryStmt |
    tryStmt.containsInScope(nextInvocation.getNode()) and
    tryStmt.getAHandler().getType() = stopIterationException().getAValueReachableFromSource().asExpr()
  )
}

// Find unguarded next() calls in generators without default value or exception handling
from CallNode nextInvocation, ControlFlowNode iteratorArgument
where
  // Verify next() call with iterator argument
  nextCallWithIterator(nextInvocation, iteratorArgument) and
  // Ensure no default value provided
  not nextCallProvidesDefault(nextInvocation) and
  // Confirm iterator might be exhausted
  not exists(EssaVariable iteratorVar |
    iteratorArgument = iteratorVar.getAUse() and
    iteratorIsNonExhausted(iteratorVar)
  ) and
  // Restrict to generator functions
  nextInvocation.getNode().getScope().(Function).isGenerator() and
  // Exclude comprehensions
  not exists(Comp comp | comp.contains(nextInvocation.getNode())) and
  // Verify no StopIteration handling
  not stopIterationIsHandled(nextInvocation) and
  // PEP 479 resolves this in Python 3.7+
  // Only alert for Python 2 since minor version is unknown
  major_version() = 2
select nextInvocation, "Call to 'next()' in a generator."