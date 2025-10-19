import python

/** @name CWE-400: Uncontrolled Resource Consumption */
/** @description Detects potential uncontrolled resource consumption via infinite loops or excessive resource allocation patterns. */

// Query for infinite loops that could lead to uncontrolled resource consumption
from WhileStmt w
where w.getCondition().isConstant(true) and 
      (w.getBody().getStatements().length > 5 or 
       exists(Stmt s | s instanceof AssignExpr and s.getTarget().getName() = "i" and s.getValue().isNull()))
select w, "Potential infinite loop leading to uncontrolled resource consumption"