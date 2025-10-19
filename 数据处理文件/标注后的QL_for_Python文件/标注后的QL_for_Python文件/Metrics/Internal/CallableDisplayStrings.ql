/**
 * @name Display strings of callables
 * @kind display-string
 * @id py/function-display-strings
 * @metricType callable
 */

// 导入Python库，用于处理Python代码的查询
import python

// 从Function类中选择函数f
from Function f
// 选择函数f和字符串"Function "加上函数名
select f, "Function " + f.getName()
