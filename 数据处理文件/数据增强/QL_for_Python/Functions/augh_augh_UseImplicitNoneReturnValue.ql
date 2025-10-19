/**
 * @name Use of procedure return value
 * @description A procedure (a function that does not return a meaningful value) is called, and its return value (None) is used. This can be confusing because the value has no meaning.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/procedure-return-value-used
 */

import python
import Testing.Mox

// Predicate to determine if a call expression's result is utilized
predicate isCallResultUsed(Call invocation) {
  // Case 1: The call is nested within another expression (call, attribute, or subscript)
  exists(Expr parentExpr | 
    parentExpr != invocation and 
    parentExpr.containsInScope(invocation) and
    (parentExpr instanceof Call or 
     parentExpr instanceof Attribute or 
     parentExpr instanceof Subscript)
  )
  // Case 2: The call is part of a statement that is not an expression statement and not a single return statement
  or
  exists(Stmt enclosingStmt |
    invocation = enclosingStmt.getASubExpression() and
    not enclosingStmt instanceof ExprStmt and
    /* Exclude single return statements (common pattern: def f(): return g()) */
    not (enclosingStmt instanceof Return and 
         strictcount(Return r | r.getScope() = enclosingStmt.getScope()) = 1)
  )
}

// Identify problematic procedure return value usage
from Call invocation, FunctionValue calleeFunction
where
  // The result of the call is used in a non-trivial way
  isCallResultUsed(invocation) and
  
  // Resolve the function being called and verify it is a procedure
  invocation.getFunc().pointsTo(calleeFunction) and
  calleeFunction.getScope().isProcedure() and
  
  // Ensure all possible callees (due to dynamic dispatch) are procedures
  forall(FunctionValue alternativeCallee | 
    invocation.getFunc().pointsTo(alternativeCallee) | 
    alternativeCallee.getScope().isProcedure()
  ) and
  
  // Exclude cases in Mox test framework modules (which use AndReturn method)
  not useOfMoxInModule(invocation.getEnclosingModule())
select invocation, 
       "The result of $@ is used even though it is always None.", 
       calleeFunction, 
       calleeFunction.getQualifiedName()