/**
 * @name Unguarded next() in generator functions
 * @description A call to next() without a default value in a generator function might cause premature termination of iteration.
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
predicate iterCallWithSource(CallNode iterCall, EssaVariable sourceSeq) {
  iterCall = iterFunction().getACall().asCfgNode() and
  iterCall.getArg(0) = sourceSeq.getAUse()
}

// Checks if a call is to next() on specified iterator
predicate nextCallOnIterator(CallNode nextCall, ControlFlowNode targetIter) {
  nextCall = nextFunction().getACall().asCfgNode() and
  nextCall.getArg(0) = targetIter
}

// Checks if sequence is guarded against emptiness
predicate isGuardedSequence(EssaVariable seq) {
  seq.getDefinition() instanceof EssaEdgeRefinement
}

/**
 * Holds if iterator is confirmed non-exhausted.
 * 
 * Detects patterns like next(iter(x)) where x is known non-empty.
 */
predicate isNonExhaustedIterator(EssaVariable iterVar) {
  exists(EssaVariable sourceSeq |
    iterCallWithSource(iterVar.getDefinition().(AssignmentDefinition).getValue(), sourceSeq) and
    isGuardedSequence(sourceSeq)
  )
}

// Checks if StopIteration exception is handled in current scope
predicate isStopIterationHandled(CallNode nextCall) {
  exists(Try tryBlock |
    tryBlock.containsInScope(nextCall.getNode()) and
    tryBlock.getAHandler().getType() = stopIterationException().getAValueReachableFromSource().asExpr()
  )
}

// Query to find unguarded next() calls in generators
from CallNode nextCall
where
  // Verify this is a next() function call
  nextCallOnIterator(nextCall, _) and
  // Ensure no default value is provided (inlined check)
  not exists(nextCall.getArg(1)) and
  not exists(nextCall.getArgByName("default")) and
  // Confirm iterator might be exhausted
  not exists(EssaVariable iterVar |
    nextCallOnIterator(nextCall, iterVar.getAUse()) and
    isNonExhaustedIterator(iterVar)
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