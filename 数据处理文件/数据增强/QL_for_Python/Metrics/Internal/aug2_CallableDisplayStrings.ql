/**
 * @name Display strings of callables
 * @kind display-string
 * @id py/function-display-strings
 * @metricType callable
 */

// 引入Python模块，提供Python代码分析的基础功能
import python

// 定义查询范围：所有Python函数对象
from Function callableObj

// 构建并输出每个函数的描述性字符串
select callableObj, "Function " + callableObj.getName()