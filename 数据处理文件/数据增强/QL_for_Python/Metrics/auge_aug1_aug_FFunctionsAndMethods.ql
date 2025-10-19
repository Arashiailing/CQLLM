/**
 * @name File-level function and method count
 * @description Provides a comprehensive analysis of Python modules by counting
 *              all user-defined functions and methods, excluding lambda expressions.
 *              This metric helps identify modules with high complexity due to
 *              excessive function definitions.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // 导入Python模块，用于代码结构分析

// 分析每个Python模块，计算其包含的函数和方法总数
from Module pyModule, int methodCount
// 计算逻辑：统计模块内所有非lambda函数定义的数量
where methodCount = count(Function functionDef | 
       // 确保函数属于当前模块
       functionDef.getEnclosingModule() = pyModule and 
       // 排除lambda表达式，只统计具名函数
       functionDef.getName() != "lambda")
// 输出结果：模块对象及其函数计数，按函数数量降序排列
select pyModule, methodCount order by methodCount desc