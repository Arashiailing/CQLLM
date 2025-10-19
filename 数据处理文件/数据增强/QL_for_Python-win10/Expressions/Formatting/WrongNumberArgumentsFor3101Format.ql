/**
 * @name Too few arguments in formatting call
 * @description A string formatting operation, such as '"{0}: {1}, {2}".format(a,b)',
 *              where the number of values to be formatted is too few for the format string will raise an IndexError.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/str-format/missing-argument
 */

import python  // 导入python库，用于处理Python代码的查询
import AdvancedFormatting  // 导入AdvancedFormatting库，用于高级格式化操作的查询

// 从以下数据源中提取信息：
from
  AdvancedFormattingCall call,  // 高级格式化调用
  AdvancedFormatString fmt,  // 高级格式化字符串
  int arg_count,  // 提供的参数数量
  int max_field,  // 格式字符串中的最大字段编号
  string provided  // 提供的参数描述
where
  arg_count = call.providedArgCount() and  // 获取提供的参数数量
  max_field = max(fmt.getFieldNumber(_, _)) and  // 获取格式字符串中的最大字段编号
  call.getAFormat() = fmt and  // 确保调用的格式与格式字符串匹配
  not exists(call.getStarargs()) and  // 确保没有使用星号参数（*args）
  arg_count <= max_field and  // 检查提供的参数数量是否小于或等于最大字段编号
  (if arg_count = 1 then provided = " is provided." else provided = " are provided.")  // 根据参数数量设置提供的描述
select call,  // 选择调用
  "Too few arguments for string format. Format $@ requires at least " + (max_field + 1) + ", but " +
    arg_count.toString() + provided, fmt, "\"" + fmt.getText() + "\""  // 生成错误消息，包含所需的最小参数数量和实际提供的参数数量
