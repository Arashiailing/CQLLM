/**
 * @name Display strings of callables
 * @kind display-string
 * @id py/function-display-strings
 * @metricType callable
 */

// 引入Python代码分析的核心模块
import python

// 定义查询范围：识别所有Python函数定义
from Function funcDef

// 构造并返回每个函数的标识字符串
select 
    funcDef, 
    "Function " + funcDef.getName()