/**
 * @name Unsupported format character
 * @description An unsupported format character in a format string
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/unsupported-character
 */

// 引入Python代码分析核心模块
import python
// 引入字符串处理相关工具模块
import semmle.python.strings

// 查询定义：检测包含非法格式说明符的表达式
from Expr formatExpr, int errorPosition
// 条件判断：定位非法格式说明符在表达式中的位置
where errorPosition = illegal_conversion_specifier(formatExpr)
// 结果输出：返回表达式及错误位置信息
select formatExpr, "Invalid conversion specifier at index " + errorPosition + " of " + repr(formatExpr) + "."