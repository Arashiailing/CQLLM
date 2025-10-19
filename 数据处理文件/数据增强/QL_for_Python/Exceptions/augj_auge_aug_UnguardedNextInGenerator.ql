/**
 * @name Unguarded next in generator
 * @description Detects unprotected next() calls in generators that could lead to unexpected iteration termination.
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

// API references for core built-ins
API::Node iterBuiltin() { result = API::builtin("iter") }
API::Node nextBuiltin() { result = API::builtin("next") }
API::Node stopIterationBuiltin() { result = API::builtin("StopIteration") }

/**
 * Holds when iterator is provably non-exhausted.
 * 
 * Typical case: next(iter(x)) where x is guarded and non-empty.
 */
predicate nonExhaustedIterator(EssaVariable iterVar) {
  exists(EssaVariable seqVar, CallNode iterCallNode |
    // Match iter() calls with sequence argument
    iterCallNode = iterBuiltin().getACall().asCfgNode() and
    iterCallNode.getArg(0) = seqVar.getAUse() and
    iterVar.getDefinition().(AssignmentDefinition).getValue() = iterCallNode and
    // Confirm sequence is guarded and non-empty
    seqVar.getDefinition() instanceof EssaEdgeRefinement
  )
}

// Checks if StopIteration is caught in current scope
predicate stopIterationHandled(CallNode nextCall) {
  exists(Try tryStmt |
    tryStmt.containsInScope(nextCall.getNode()) and
    tryStmt.getAHandler().getType() = stopIterationBuiltin().getAValueReachableFromSource().asExpr()
  )
}

// Identify unguarded next() calls in generators
from CallNode nextCall, ControlFlowNode iterNode
where
  // Validate next() call structure
  nextCall = nextBuiltin().getACall().asCfgNode() and
  nextCall.getArg(0) = iterNode and
  not exists(nextCall.getArg(1)) and
  not exists(nextCall.getArgByName("default")) and
  
  // Verify iterator might be exhausted
  not exists(EssaVariable iterVar |
    iterNode = iterVar.getAUse() and
    nonExhaustedIterator(iterVar)
  ) and
  
  // Restrict to generator context
  nextCall.getNode().getScope().(Function).isGenerator() and
  not exists(Comp comp | comp.contains(nextCall.getNode())) and
  
  // Confirm no exception handling
  not stopIterationHandled(nextCall) and
  
  // Only relevant for Python 2 (PEP 479 fixes this in 3.7+)
  major_version() = 2
select nextCall, "Call to 'next()' in a generator."