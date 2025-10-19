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
predicate iterCallWithSource(CallNode iterCallNode, EssaVariable sourceSequence) {
  iterCallNode = iterFunction().getACall().asCfgNode() and
  iterCallNode.getArg(0) = sourceSequence.getAUse()
}

// Checks if a call is to next() on specified iterator
predicate nextCallOnIterator(CallNode nextCallNode, ControlFlowNode targetIterator) {
  nextCallNode = nextFunction().getACall().asCfgNode() and
  nextCallNode.getArg(0) = targetIterator
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
predicate isNonExhaustedIterator(EssaVariable iteratorVariable) {
  exists(EssaVariable sourceSequence |
    iterCallWithSource(iteratorVariable.getDefinition().(AssignmentDefinition).getValue(), sourceSequence) and
    isGuardedSequence(sourceSequence)
  )
}

// Checks if StopIteration exception is handled in current scope
predicate isStopIterationHandled(CallNode nextCallNode) {
  exists(Try tryBlock |
    tryBlock.containsInScope(nextCallNode.getNode()) and
    tryBlock.getAHandler().getType() = stopIterationException().getAValueReachableFromSource().asExpr()
  )
}

// Query to find unguarded next() calls in generators
from CallNode nextCallNode
where
  // Verify this is a next() function call without default value
  nextCallOnIterator(nextCallNode, _) and
  not exists(nextCallNode.getArg(1)) and
  not exists(nextCallNode.getArgByName("default")) and
  
  // Confirm iterator might be exhausted
  not exists(EssaVariable iteratorVariable |
    nextCallOnIterator(nextCallNode, iteratorVariable.getAUse()) and
    isNonExhaustedIterator(iteratorVariable)
  ) and
  
  // Restrict to generator functions
  nextCallNode.getNode().getScope().(Function).isGenerator() and
  
  // Exclude comprehensions
  not exists(Comp comprehension | comprehension.contains(nextCallNode.getNode())) and
  
  // Verify no StopIteration handling
  not isStopIterationHandled(nextCallNode) and
  
  // PEP 479 resolved this issue in Python 3.7+
  // We only flag for Python 2 since minor version isn't detectable
  major_version() = 2
select nextCallNode, "Call to 'next()' in a generator."