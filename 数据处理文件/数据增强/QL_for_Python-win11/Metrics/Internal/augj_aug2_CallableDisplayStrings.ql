/**
 * @name Display strings of callables
 * @kind display-string
 * @id py/function-display-strings
 * @metricType callable
 */

// 导入Python语言分析模块，提供基础分析功能
import python

// 从所有Python函数定义中选择
from Function func

// 生成并输出每个函数的描述信息
select func, "Function " + func.getName()