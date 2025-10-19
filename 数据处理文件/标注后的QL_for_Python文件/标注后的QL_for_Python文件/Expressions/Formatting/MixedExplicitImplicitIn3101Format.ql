/**
 * @name Formatting string mixes implicitly and explicitly numbered fields
 * @description Using implicit and explicit numbering in string formatting operations, such as '"{}: {1}".format(a,b)', will raise a ValueError.
 * @kind problem
 * @problem.severity error
 * @tags reliability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/str-format/mixed-fields
 */

import python  // 导入Python库，用于分析Python代码
import AdvancedFormatting  // 导入高级格式化库，用于处理复杂的字符串格式化操作

// 从AdvancedFormattingCall和AdvancedFormatString中获取call和fmt对象
from AdvancedFormattingCall call, AdvancedFormatString fmt
// 条件：call对象的格式化字符串等于fmt对象，并且fmt对象同时包含隐式编号和显式编号的字段
where call.getAFormat() = fmt and fmt.isImplicitlyNumbered() and fmt.isExplicitlyNumbered()
// 选择符合条件的fmt对象，并报告错误信息
select fmt, "Formatting string mixes implicitly and explicitly numbered fields."
