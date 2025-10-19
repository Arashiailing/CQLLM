/**
 * @name Display strings of callables
 * @kind display-string
 * @id py/function-display-strings
 * @metricType callable
 */

// 导入Python语言分析模块，为代码分析提供基础支持
import python

// 指定查询目标：筛选所有Python函数定义
from Function func
where exists(func.getName())  // 确保函数具有有效名称

// 生成并返回每个函数的标识信息字符串
select func, "Function " + func.getName()