/**
 * @name Use of the return value of a procedure
 * @description Detects improper usage of return values from procedures (functions that always return None). 
 *              Such usage is misleading since the returned value has no semantic meaning.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/procedure-return-value-used
 */

import python
import Testing.Mox

// Determines whether a function call's return value is actually utilized in the code
predicate isCallResultUsed(Call callNode) {
  // Case 1: Call is nested inside an expression requiring a value
  exists(Expr parentExpr | 
    parentExpr != callNode and 
    parentExpr.containsInScope(callNode) and
    (parentExpr instanceof Call or 
     parentExpr instanceof Attribute or 
     parentExpr instanceof Subscript)
  )
  // Case 2: Call appears in a statement context expecting a value (not standalone)
  or
  exists(Stmt enclosingStmt |
    callNode = enclosingStmt.getASubExpression() and
    not enclosingStmt instanceof ExprStmt and
    // Exclude single return statements as conventional patterns
    not (enclosingStmt instanceof Return and 
         strictcount(Return r | r.getScope() = enclosingStmt.getScope()) = 1)
  )
}

// Identify procedure calls where return values are improperly utilized
from Call callNode, FunctionValue calledFunction
where
  // Check if return value is used
  isCallResultUsed(callNode) and
  // Verify call targets a specific function
  callNode.getFunc().pointsTo(calledFunction) and
  // Ensure target function is a procedure (returns None)
  calledFunction.getScope().isProcedure() and
  // Handle polymorphic cases: all possible callees must be procedures
  forall(FunctionValue potentialCallee | 
    callNode.getFunc().pointsTo(potentialCallee) | 
    potentialCallee.getScope().isProcedure()
  ) and
  // Exclude modules using Mox testing framework
  not useOfMoxInModule(callNode.getEnclosingModule())
select callNode, 
       "The result of $@ is used even though it is always None.", 
       calledFunction, 
       calledFunction.getQualifiedName()