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

// 导入Python库，用于处理Python代码的解析和分析
import python
// 导入字符串处理相关的库
import semmle.python.strings

// 定义查询语句，从表达式e和整数start中进行选择
from Expr e, int start
// 条件：start等于非法转换说明符的位置
where start = illegal_conversion_specifier(e)
// 选择表达式e，并生成错误信息，指出非法转换说明符的位置和内容
select e, "Invalid conversion specifier at index " + start + " of " + repr(e) + "."
