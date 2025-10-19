/**
 * @name Number of statements
 * @description Calculates and visualizes the quantity of statements in each Python module.
 *              This metric helps identify potentially complex files that may require refactoring.
 * @kind treemap
 * @id py/number-of-statements-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // 导入Python语言库，用于分析Python代码结构

// 定义查询结果的返回类型：Python模块及其包含的语句数量
from Module pythonModule, int statementCount
// 过滤条件：统计每个模块中包含的所有语句
where 
    // 对于每个语句，检查其所属模块是否与当前分析的模块相同
    statementCount = count(Stmt statement | statement.getEnclosingModule() = pythonModule)
// 选择模块和对应的语句数量，按语句数量降序排列以便识别最复杂的文件
select pythonModule, statementCount order by statementCount desc