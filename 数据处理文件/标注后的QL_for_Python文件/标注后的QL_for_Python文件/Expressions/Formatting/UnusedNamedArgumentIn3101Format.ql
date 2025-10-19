/**
 * @name Unused named argument in formatting call
 * @description Including surplus keyword arguments in a formatting call makes code more difficult to read and may indicate an error.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/str-format/surplus-named-argument
 */

import python  // 导入python库，用于分析Python代码
import AdvancedFormatting  // 导入AdvancedFormatting库，用于高级格式化操作

// 从AdvancedFormattingCall中获取调用信息，从AdvancedFormatString中获取格式字符串，并定义两个字符串变量name和fmt_repr
from AdvancedFormattingCall call, AdvancedFormatString fmt, string name, string fmt_repr
where
  // 获取调用中的格式字符串并与fmt进行比较
  call.getAFormat() = fmt and
  // 获取调用中的关键字参数的名称并与name进行比较
  name = call.getAKeyword().getArg() and
  // 确保格式字符串中没有使用到该名称的字段
  forall(AdvancedFormatString format | format = call.getAFormat() |
    not format.getFieldName(_, _) = name
  ) and
  // 确保调用中没有其他关键字参数
  not exists(call.getKwargs()) and
  (
    // 如果只有一个格式字符串，则设置fmt_repr为该格式字符串的文本表示
    strictcount(call.getAFormat()) = 1 and fmt_repr = "format \"" + fmt.getText() + "\""
    or
    // 如果有多个格式字符串，则设置fmt_repr为任意格式字符串的表示
    strictcount(call.getAFormat()) != 1 and fmt_repr = "any format used."
  )
select call,
  // 选择调用，并提供警告信息，指出多余的命名参数及其对应的格式字符串
  "Surplus named argument for string format. An argument named '" + name +
    "' is provided, but it is not required by $@.", fmt, fmt_repr
