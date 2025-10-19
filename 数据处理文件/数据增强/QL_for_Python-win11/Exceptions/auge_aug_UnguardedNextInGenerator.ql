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

// API node references for built-in functions and exception
API::Node iterBuiltin() { result = API::builtin("iter") }
API::Node nextBuiltin() { result = API::builtin("next") }
API::Node stopIterationBuiltin() { result = API::builtin("StopIteration") }

/**
 * Holds if iterator is guaranteed non-exhausted.
 * 
 * Common pattern: next(iter(x)) where x is known non-empty.
 */
predicate nonExhaustedIterator(EssaVariable iteratorVar) {
  exists(EssaVariable sequenceVar, CallNode iterCall |
    // Identify iter() calls with specified sequence argument
    iterCall = iterBuiltin().getACall().asCfgNode() and
    iterCall.getArg(0) = sequenceVar.getAUse() and
    iteratorVar.getDefinition().(AssignmentDefinition).getValue() = iterCall and
    // Verify sequence is guarded and non-empty
    sequenceVar.getDefinition() instanceof EssaEdgeRefinement
  )
}

// Checks if StopIteration exception is handled in scope
predicate stopIterationHandled(CallNode nextCallNode) {
  exists(Try tryBlock |
    tryBlock.containsInScope(nextCallNode.getNode()) and
    tryBlock.getAHandler().getType() = stopIterationBuiltin().getAValueReachableFromSource().asExpr()
  )
}

// Find unguarded next() calls in generators without default value or exception handling
from CallNode nextCallNode, ControlFlowNode iteratorNode
where
  // Verify next() call with iterator argument
  nextCallNode = nextBuiltin().getACall().asCfgNode() and
  nextCallNode.getArg(0) = iteratorNode and
  // Ensure no default value provided
  not exists(nextCallNode.getArg(1)) and
  not exists(nextCallNode.getArgByName("default")) and
  // Confirm iterator might be exhausted
  not exists(EssaVariable iteratorVar |
    iteratorNode = iteratorVar.getAUse() and
    nonExhaustedIterator(iteratorVar)
  ) and
  // Restrict to generator functions
  nextCallNode.getNode().getScope().(Function).isGenerator() and
  // Exclude comprehensions
  not exists(Comp comp | comp.contains(nextCallNode.getNode())) and
  // Verify no StopIteration handling
  not stopIterationHandled(nextCallNode) and
  // PEP 479 resolves this in Python 3.7+
  // Only alert for Python 2 since minor version is unknown
  major_version() = 2
select nextCallNode, "Call to 'next()' in a generator."