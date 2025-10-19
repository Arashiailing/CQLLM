/**
 * @name File Line Count Analysis
 * @description Calculates and displays the number of lines in each Python file.
 *              This metric helps identify potentially large files that might
 *              need refactoring or further investigation.
 * @kind treemap
 * @id py/lines-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python

// 查询每个Python文件的行数
from Module pythonModule, int lineCount
where 
    // 获取每个模块的行数
    lineCount = pythonModule.getMetrics().getNumberOfLines()
select 
    // 输出模块和对应的行数，按行数降序排列
    pythonModule, lineCount 
order by 
    lineCount desc