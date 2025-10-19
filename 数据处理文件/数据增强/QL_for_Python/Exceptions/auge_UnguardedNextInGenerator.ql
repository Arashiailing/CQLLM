/**
 * @name Unguarded next in generator
 * @description Calling next() in a generator may cause unintended early termination of an iteration.
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

// API node definitions for built-in functions and exceptions
API::Node iterFunction() { result = API::builtin("iter") }
API::Node nextFunction() { result = API::builtin("next") }
API::Node stopIterationException() { result = API::builtin("StopIteration") }

// Checks if a call is to iter() with specified sequence source
predicate iterCallWithSource(CallNode iterInvocation, EssaVariable sourceSequence) {
  iterInvocation = iterFunction().getACall().asCfgNode() and
  iterInvocation.getArg(0) = sourceSequence.getAUse()
}

// Checks if a call is to next() on specified iterator
predicate nextCallOnIterator(CallNode nextInvocation, ControlFlowNode targetIterator) {
  nextInvocation = nextFunction().getACall().asCfgNode() and
  nextInvocation.getArg(0) = targetIterator
}

// Checks if next() call has default value parameter
predicate nextCallHasDefault(CallNode nextInvocation) {
  exists(nextInvocation.getArg(1)) or exists(nextInvocation.getArgByName("default"))
}

// Checks if sequence is guarded against emptiness
predicate isGuardedSequence(EssaVariable sequence) {
  sequence.getDefinition() instanceof EssaEdgeRefinement
}

/**
 * Holds if iterator is confirmed non-exhausted.
 * 
 * Detects patterns like next(iter(x)) where x is known non-empty.
 */
predicate isNonExhaustedIterator(EssaVariable iterator) {
  exists(EssaVariable sourceSequence |
    iterCallWithSource(iterator.getDefinition().(AssignmentDefinition).getValue(), sourceSequence) and
    isGuardedSequence(sourceSequence)
  )
}

// Checks if StopIteration exception is handled in current scope
predicate isStopIterationHandled(CallNode nextInvocation) {
  exists(Try tryBlock |
    tryBlock.containsInScope(nextInvocation.getNode()) and
    tryBlock.getAHandler().getType() = stopIterationException().getAValueReachableFromSource().asExpr()
  )
}

// Query to find unguarded next() calls in generators
from CallNode nextCall
where
  // Verify this is a next() function call
  nextCallOnIterator(nextCall, _) and
  // Ensure no default value is provided
  not nextCallHasDefault(nextCall) and
  // Confirm iterator might be exhausted
  not exists(EssaVariable iterator |
    nextCallOnIterator(nextCall, iterator.getAUse()) and
    isNonExhaustedIterator(iterator)
  ) and
  // Restrict to generator functions
  nextCall.getNode().getScope().(Function).isGenerator() and
  // Exclude comprehensions
  not exists(Comp comprehension | comprehension.contains(nextCall.getNode())) and
  // Verify no StopIteration handling
  not isStopIterationHandled(nextCall) and
  // PEP 479 resolved this issue in Python 3.7+
  // We only flag for Python 2 since minor version isn't detectable
  major_version() = 2
select nextCall, "Call to 'next()' in a generator."