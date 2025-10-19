import python

/**
 * This query detects CWE-22: Improper Neutralization of Special Elements used in an OS Command ('OS Command Injection').
 * It identifies cases where user-controlled data is used in a path expression.
 */

from PathExpr pathExpr, Expr userControlledData
where pathExpr.getArgument(0) = userControlledData
select pathExpr, "This path expression uses user-controlled data, which can lead to path injection."