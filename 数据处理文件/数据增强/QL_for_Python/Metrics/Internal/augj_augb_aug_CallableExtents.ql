/**
 * @name Extents of callables
 * @kind extent
 * @id py/function-extents
 * @metricType callable
 */

// 引入Python代码分析的核心模块，用于访问和分析Python代码结构
import python

// 定义查询目标：检索所有Python可调用函数实体
from Function pyFunction

// 返回每个函数的源代码位置信息及其对应的函数对象引用
select pyFunction.getLocation(), pyFunction