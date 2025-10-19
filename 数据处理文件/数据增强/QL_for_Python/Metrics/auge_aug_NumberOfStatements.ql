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

// 声明查询结果变量：源代码模块及其包含的语句数量
from Module sourceModule, int stmtQuantity
// 计算每个模块中语句的总数量
where 
    // 聚合统计：遍历所有语句，计算属于当前模块的语句数量
    stmtQuantity = count(Stmt stmt | stmt.getEnclosingModule() = sourceModule)
// 返回结果集：模块对象及其对应的语句数量，按语句数量降序排序
select sourceModule, stmtQuantity order by stmtQuantity desc