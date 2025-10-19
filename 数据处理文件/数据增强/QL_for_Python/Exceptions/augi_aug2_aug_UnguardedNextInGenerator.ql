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

// Identifies iter() calls operating on specified sequence variables
predicate iterCallOnSequence(CallNode iterCallNode, EssaVariable sourceSequenceVar) {
  iterCallNode = builtinIter().getACall().asCfgNode() and
  iterCallNode.getArg(0) = sourceSequenceVar.getAUse()
}

// Identifies next() calls with specified iterator argument
predicate nextCallOnIterator(CallNode nextCallNode, ControlFlowNode iteratorArgNode) {
  nextCallNode = builtinNext().getACall().asCfgNode() and
  nextCallNode.getArg(0) = iteratorArgNode
}

// Checks if next() call provides a default value
predicate nextCallWithDefault(CallNode nextCallNode) {
  exists(nextCallNode.getArg(1)) or exists(nextCallNode.getArgByName("default"))
}

// Checks if sequence is guarded and non-empty
predicate isGuardedSequence(EssaVariable sourceSequenceVar) {
  sourceSequenceVar.getDefinition() instanceof EssaEdgeRefinement
}

/**
 * Holds if iterator is guaranteed non-exhausted.
 * 
 * Common pattern: next(iter(x)) where x is known non-empty.
 */
predicate isNonExhaustedIterator(EssaVariable iteratorVariable) {
  exists(EssaVariable sourceSequenceVar |
    iterCallOnSequence(iteratorVariable.getDefinition().(AssignmentDefinition).getValue(), sourceSequenceVar) and
    isGuardedSequence(sourceSequenceVar)
  )
}

// Checks if StopIteration exception is handled in scope
predicate isStopIterationHandled(CallNode nextCallNode) {
  exists(Try tryBlock |
    tryBlock.containsInScope(nextCallNode.getNode()) and
    tryBlock.getAHandler().getType() = builtinStopIteration().getAValueReachableFromSource().asExpr()
  )
}

// Find unguarded next() calls in generators without default value or exception handling
from CallNode nextCallNode, ControlFlowNode iteratorArgNode
where
  // Restrict to generator functions (excluding comprehensions)
  nextCallNode.getNode().getScope().(Function).isGenerator() and
  not exists(Comp comp | comp.contains(nextCallNode.getNode())) and
  
  // Verify next() call with iterator argument
  nextCallOnIterator(nextCallNode, iteratorArgNode) and
  
  // Ensure no default value provided
  not nextCallWithDefault(nextCallNode) and
  
  // Confirm iterator might be exhausted
  not exists(EssaVariable iteratorVariable |
    iteratorArgNode = iteratorVariable.getAUse() and
    isNonExhaustedIterator(iteratorVariable)
  ) and
  
  // Verify no StopIteration handling
  not isStopIterationHandled(nextCallNode) and
  
  // PEP 479 resolves this in Python 3.7+
  // Only alert for Python 2 since minor version is unknown
  major_version() = 2
select nextCallNode, "Call to 'next()' in a generator."