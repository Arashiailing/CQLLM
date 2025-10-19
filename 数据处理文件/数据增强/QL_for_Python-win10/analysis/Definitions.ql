/**
 * @name Definitions
 * @description Jump to definition helper query.
 * @kind definitions
 * @id py/jump-to-definition
 */

// 导入Python库，用于处理Python代码的查询
import python

// 导入分析定义跟踪模块，用于跟踪变量和函数的定义
import analysis.DefinitionTracking

// 从NiceLocationExpr使用、定义和字符串类型中选择数据
from NiceLocationExpr use, Definition defn, string kind
// 条件：定义与使用匹配，并且类型相同
where defn = definitionOf(use, kind)
// 选择使用位置、定义位置和定义类型
select use, defn, kind
