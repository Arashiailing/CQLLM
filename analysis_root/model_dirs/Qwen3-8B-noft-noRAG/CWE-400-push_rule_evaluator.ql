import python

from CallExpr c, Argument arg, Variable var
where 
  c.getCallee().getName() = "input" and 
  arg.getArgPos() = 0 and 
  var = arg.getVariable()
select var, "Potential CWE-400: Uncontrolled Resource Consumption via unbounded input"