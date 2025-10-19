import python

/**
 * @name CWE-400: Uncontrolled Resource Consumption
 */
from Loop loop
where loop.isWhile()
  and loop.getCondition().getExpression().isLiteral(true)
  and not exists BreakStmt b
      where b.getParent() = loop.getBody()
select loop.getLocation(), "Potential infinite loop causing uncontrolled resource consumption"