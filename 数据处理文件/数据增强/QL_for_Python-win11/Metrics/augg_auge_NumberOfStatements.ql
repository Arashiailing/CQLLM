/**
 * @name Number of statements
 * @description Calculates the total count of statements within each Python module.
 *              This metric helps identify files with high complexity that might
 *              benefit from refactoring.
 * @kind treemap
 * @id py/number-of-statements-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // 导入Python语言库，用于代码分析

// 定义查询范围：遍历所有Python模块
from Module moduleObj
// 计算每个模块中包含的语句总数并输出结果
select moduleObj, count(Stmt currentStmt | currentStmt.getEnclosingModule() = moduleObj) as stmtCount 
order by stmtCount desc