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
predicate nonExhaustedIterator(EssaVariable iterVar) {
  exists(EssaVariable seqVar, CallNode iterCall |
    // Identify iter() calls with specified sequence argument
    iterCall = iterBuiltin().getACall().asCfgNode() and
    iterCall.getArg(0) = seqVar.getAUse() and
    iterVar.getDefinition().(AssignmentDefinition).getValue() = iterCall and
    // Verify sequence is guarded and non-empty
    seqVar.getDefinition() instanceof EssaEdgeRefinement
  )
}

// Checks if StopIteration exception is handled in scope
predicate stopIterationHandled(CallNode nextCall) {
  exists(Try tryBlock |
    tryBlock.containsInScope(nextCall.getNode()) and
    tryBlock.getAHandler().getType() = stopIterationBuiltin().getAValueReachableFromSource().asExpr()
  )
}

// Find unguarded next() calls in generators without default value or exception handling
from CallNode nextCall, ControlFlowNode iterArgNode
where
  // Verify next() call with iterator argument
  nextCall = nextBuiltin().getACall().asCfgNode() and
  nextCall.getArg(0) = iterArgNode and
  // Ensure no default value provided
  not exists(nextCall.getArg(1)) and
  not exists(nextCall.getArgByName("default")) and
  // Confirm iterator might be exhausted
  not exists(EssaVariable iterVar |
    iterArgNode = iterVar.getAUse() and
    nonExhaustedIterator(iterVar)
  ) and
  // Restrict to generator functions
  nextCall.getNode().getScope().(Function).isGenerator() and
  // Exclude comprehensions
  not exists(Comp comp | comp.contains(nextCall.getNode())) and
  // Verify no StopIteration handling
  not stopIterationHandled(nextCall) and
  // PEP 479 resolves this in Python 3.7+
  // Only alert for Python 2 since minor version is unknown
  major_version() = 2
select nextCall, "Call to 'next()' in a generator."