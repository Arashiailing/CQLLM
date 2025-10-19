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
predicate iterCallWithSequence(CallNode iterInvocation, EssaVariable sequenceVar) {
  iterInvocation = iterApiNode().getACall().asCfgNode() and
  iterInvocation.getArg(0) = sequenceVar.getAUse()
}

// Matches next() calls with specific iterator argument
predicate nextCallWithIterator(CallNode nextInvocation, ControlFlowNode iteratorNode) {
  nextInvocation = nextApiNode().getACall().asCfgNode() and
  nextInvocation.getArg(0) = iteratorNode
}

// Checks if next() call includes default value parameter
predicate nextCallHasDefault(CallNode nextInvocation) {
  exists(nextInvocation.getArg(1)) or exists(nextInvocation.getArgByName("default"))
}

// Determines if sequence has non-empty guard
predicate sequenceHasGuard(EssaVariable sequenceVar) {
  sequenceVar.getDefinition() instanceof EssaEdgeRefinement
}

/**
 * Holds if iterator is guaranteed to have remaining elements.
 * 
 * Common pattern: next(iter(x)) where x is known non-empty.
 */
predicate iteratorIsNonExhausted(EssaVariable iteratorVar) {
  exists(EssaVariable sequenceVar |
    iterCallWithSequence(iteratorVar.getDefinition().(AssignmentDefinition).getValue(), sequenceVar) and
    sequenceHasGuard(sequenceVar)
  )
}

// Checks if StopIteration exception is handled in current scope
predicate stopIterationIsHandled(CallNode nextInvocation) {
  exists(Try tryBlock |
    tryBlock.containsInScope(nextInvocation.getNode()) and
    tryBlock.getAHandler().getType() = stopIterationApiNode().getAValueReachableFromSource().asExpr()
  )
}

// Find unguarded next() calls in generators without default value or exception handling
from CallNode nextInvocation, ControlFlowNode iteratorNode
where
  // Verify next() call with iterator argument
  nextCallWithIterator(nextInvocation, iteratorNode) and
  // Ensure no default value provided
  not nextCallHasDefault(nextInvocation) and
  // Confirm iterator might be exhausted
  not exists(EssaVariable iteratorVar |
    iteratorNode = iteratorVar.getAUse() and
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