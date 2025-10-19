import python

/**
 * This query detects potential CWE-400: Uncontrolled Resource Consumption
 * vulnerabilities in Python code by looking for loops that may lead to
 * excessive resource usage.
 */

from Loop loop, StringExpr strExpr
where loop.getLoopCondition() = strExpr and
      strExpr.hasSubString(".*")
select loop, "This loop may lead to uncontrolled resource consumption due to potentially large input strings."