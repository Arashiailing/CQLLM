import semmle.python.Python

from WhileStmt w
where w.getCondition().getExpression().toString() = "True"
select w, "Infinite loop detected due to 'while True' condition."

from Function f, CallExpr c
where c.getFunction() = f and c.getFunction().getName() = f.getName()
select f, "Recursive function call without termination condition detected."