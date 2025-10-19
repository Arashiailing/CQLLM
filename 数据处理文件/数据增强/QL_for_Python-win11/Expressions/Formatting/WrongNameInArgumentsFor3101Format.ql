/**
 * @name Missing named arguments in formatting call
 * @description A string formatting operation, such as '"{name}".format(key=b)',
 *              where the names of format items in the format string differs from the names of the values to be formatted will raise a KeyError.
 * @kind problem
 * @problem.severity error
 * @tags reliability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/str-format/missing-named-argument
 */

import python // 导入python库，用于处理Python代码的查询
import AdvancedFormatting // 导入AdvancedFormatting库，用于高级格式化操作的处理

// 从AdvancedFormattingCall和AdvancedFormatString中提取call、fmt和name
from AdvancedFormattingCall call, AdvancedFormatString fmt, string name
where
  call.getAFormat() = fmt and // 确保调用的格式化对象与格式字符串匹配
  not name = call.getAKeyword().getArg() and // 检查名称是否与关键字参数不匹配
  fmt.getFieldName(_, _) = name and // 检查格式字符串中的字段名称是否与给定的名称匹配
  not exists(call.getKwargs()) // 确保没有其他关键字参数存在
select call, // 选择调用点
  "Missing named argument for string format. Format $@ requires '" + name + "', but it is omitted.", // 生成错误信息，指出缺少的命名参数
  fmt, "\"" + fmt.getText() + "\"" // 显示相关的格式字符串
