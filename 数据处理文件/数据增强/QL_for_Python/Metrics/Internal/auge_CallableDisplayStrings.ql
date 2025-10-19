/**
 * @name Display strings of callables
 * @kind display-string
 * @id py/function-display-strings
 * @metricType callable
 */

// 导入Python分析库，提供对Python代码结构的访问能力
import python

// 查询所有Python函数对象
from Function func
// 构造函数的显示字符串
select func, "Function " + func.getName()