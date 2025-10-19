import python

from WhileStmt w
where 
  let cond = w.getWhileCondition()
  let vars = cond.getVariables()
  not exists (w.getLoopBody().getStatements() as stmt 
    where stmt instanceof AssignStmt 
      and stmt.getAssignedVariables() overlaps vars)
select w, "Potential infinite loop: loop condition variables not modified in loop body."