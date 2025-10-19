/**
 * @name Statement Count Analysis
 * @description Analyzes and visualizes the number of statements within each Python module.
 *              This metric serves as an indicator of file complexity, helping developers
 *              identify modules that might benefit from refactoring or decomposition.
 * @kind treemap
 * @id py/statement-count-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python

from Module moduleObj, int statementCount
where 
    statementCount = count(
        Stmt currentStatement | 
        currentStatement.getEnclosingModule() = moduleObj
    )
select moduleObj, statementCount order by statementCount desc