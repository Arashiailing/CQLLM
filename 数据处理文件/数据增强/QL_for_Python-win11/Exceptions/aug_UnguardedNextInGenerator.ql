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
API::Node iterBuiltin() { result = API::builtin("iter") }

// API node for built-in next() function
API::Node nextBuiltin() { result = API::builtin("next") }

// API node for built-in StopIteration exception
API::Node stopIterationBuiltin() { result = API::builtin("StopIteration") }

// Identifies iter() calls with specified sequence argument
predicate iterCallWithSequence(CallNode iterCall, EssaVariable inputSeq) {
  iterCall = iterBuiltin().getACall().asCfgNode() and
  iterCall.getArg(0) = inputSeq.getAUse()
}

// Identifies next() calls with specified iterator argument
predicate nextCallWithIterator(CallNode nextCall, ControlFlowNode iterNode) {
  nextCall = nextBuiltin().getACall().asCfgNode() and
  nextCall.getArg(0) = iterNode
}

// Checks if next() call provides a default value
predicate nextCallHasDefault(CallNode nextCall) {
  exists(nextCall.getArg(1)) or exists(nextCall.getArgByName("default"))
}

// Checks if sequence is guarded and non-empty
predicate guardedSequence(EssaVariable inputSeq) {
  inputSeq.getDefinition() instanceof EssaEdgeRefinement
}

/**
 * Holds if iterator is guaranteed non-exhausted.
 * 
 * Common pattern: next(iter(x)) where x is known non-empty.
 */
predicate nonExhaustedIterator(EssaVariable iterVar) {
  exists(EssaVariable inputSeq |
    iterCallWithSequence(iterVar.getDefinition().(AssignmentDefinition).getValue(), inputSeq) and
    guardedSequence(inputSeq)
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
from CallNode nextCall, ControlFlowNode iterNode
where
  // Verify next() call with iterator argument
  nextCallWithIterator(nextCall, iterNode) and
  // Ensure no default value provided
  not nextCallHasDefault(nextCall) and
  // Confirm iterator might be exhausted
  not exists(EssaVariable iterVar |
    iterNode = iterVar.getAUse() and
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