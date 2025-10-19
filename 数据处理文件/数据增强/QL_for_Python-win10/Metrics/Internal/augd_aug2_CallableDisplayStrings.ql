/**
 * @name Display strings of callables
 * @kind display-string
 * @id py/function-display-strings
 * @metricType callable
 */

// 导入Python语言分析模块，提供基础分析能力
import python

// 查询目标：所有Python函数定义
from Function pythonFunction

// 为每个函数生成描述性字符串并展示
select pythonFunction, "Function " + pythonFunction.getName()