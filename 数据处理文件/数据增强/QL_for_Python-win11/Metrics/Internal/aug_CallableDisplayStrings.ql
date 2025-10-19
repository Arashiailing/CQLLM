/**
 * @name Display strings of callables
 * @kind display-string
 * @id py/function-display-strings
 * @metricType callable
 */

// 引入Python代码分析模块，提供对Python代码结构的访问能力
import python

// 遍历所有Python函数定义
from Function func
// 构造并返回函数描述信息，包含固定前缀和函数名称
select func, "Function " + func.getName()