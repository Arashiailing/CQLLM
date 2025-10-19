import python

/**
 * CWE-835: Loop with Unreachable Exit Condition ('Infinite Loop')
 */
from Loop loop
where not exists(Expr exitCondition | loop.getExitCondition() = exitCondition)
select loop, "This loop has an unreachable exit condition and may be an infinite loop."