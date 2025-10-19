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

// API node references for built-in functions and exceptions
API::Node builtinIter() { result = API::builtin("iter") }

API::Node builtinNext() { result = API::builtin("next") }

API::Node builtinStopIteration() { result = API::builtin("StopIteration") }

// Identifies iter() function calls operating on a specific sequence
predicate iterCallOnSequence(CallNode iterInvocation, EssaVariable sequenceVar) {
  iterInvocation = builtinIter().getACall().asCfgNode() and
  iterInvocation.getArg(0) = sequenceVar.getAUse()
}

// Identifies next() function calls operating on a specific iterator
predicate nextCallOnIterator(CallNode nextInvocation, ControlFlowNode iteratorNode) {
  nextInvocation = builtinNext().getACall().asCfgNode() and
  nextInvocation.getArg(0) = iteratorNode
}

// Determines if a next() call includes a default value parameter
predicate nextCallWithDefault(CallNode nextInvocation) {
  exists(nextInvocation.getArg(1)) or exists(nextInvocation.getArgByName("default"))
}

// Checks if a sequence is protected and guaranteed to be non-empty
predicate isGuardedSequence(EssaVariable sequenceVar) {
  sequenceVar.getDefinition() instanceof EssaEdgeRefinement
}

/**
 * Determines if an iterator is guaranteed to be non-exhausted.
 * 
 * This typically occurs with patterns like next(iter(x)) where x is known to be non-empty.
 */
predicate isNonExhaustedIterator(EssaVariable iteratorVar) {
  exists(EssaVariable sequenceVar |
    iterCallOnSequence(iteratorVar.getDefinition().(AssignmentDefinition).getValue(), sequenceVar) and
    isGuardedSequence(sequenceVar)
  )
}

// Verifies if StopIteration exception is properly handled within the current scope
predicate isStopIterationHandled(CallNode nextInvocation) {
  exists(Try tryBlock |
    tryBlock.containsInScope(nextInvocation.getNode()) and
    tryBlock.getAHandler().getType() = builtinStopIteration().getAValueReachableFromSource().asExpr()
  )
}

// Main query logic: Find unguarded next() calls in generators without proper safeguards
from CallNode nextInvocation, ControlFlowNode iteratorNode
where
  // Confirm this is a next() call with an iterator argument
  nextCallOnIterator(nextInvocation, iteratorNode) and
  // Ensure no default value is provided for the next() call
  not nextCallWithDefault(nextInvocation) and
  // Verify the iterator might be exhausted (not guaranteed to be non-exhausted)
  not exists(EssaVariable iteratorVar |
    iteratorNode = iteratorVar.getAUse() and
    isNonExhaustedIterator(iteratorVar)
  ) and
  // Restrict analysis to generator functions only
  nextInvocation.getNode().getScope().(Function).isGenerator() and
  // Exclude comprehensions from analysis
  not exists(Comp comp | comp.contains(nextInvocation.getNode())) and
  // Confirm no StopIteration exception handling is present
  not isStopIterationHandled(nextInvocation) and
  // PEP 479 addresses this issue in Python 3.7+
  // Therefore, only flag this as an issue for Python 2 (since minor version is unknown)
  major_version() = 2
select nextInvocation, "Call to 'next()' in a generator."