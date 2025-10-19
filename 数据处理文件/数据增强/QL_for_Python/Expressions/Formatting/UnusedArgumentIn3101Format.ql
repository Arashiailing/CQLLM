/**
 * @name Unused argument in a formatting call
 * @description Including surplus arguments in a formatting call makes code more difficult to read and may indicate an error.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity high
 * @precision high
 * @id py/str-format/surplus-argument
 */

import python
import AdvancedFormatting

// 计算格式化字符串中的字段数量
int field_count(AdvancedFormatString fmt) { 
    result = max(fmt.getFieldNumber(_, _)) + 1 
}

// 从高级格式化调用中选择出多余的参数
from AdvancedFormattingCall call, AdvancedFormatString fmt, int arg_count, int max_field
where
    arg_count = call.providedArgCount() and // 获取提供的参数数量
    max_field = field_count(fmt) and // 计算格式化字符串中的字段数量
    call.getAFormat() = fmt and // 确保调用的格式与给定的格式匹配
    not exists(call.getStarargs()) and // 确保没有使用星号参数（*args）
    forall(AdvancedFormatString other | other = call.getAFormat() | field_count(other) < arg_count) // 确保所有其他格式字符串的字段数量小于提供的参数数量
select call,
    "Too many arguments for string format. Format $@ requires only " + max_field + ", but " +
    arg_count.toString() + " are provided.", fmt, "\"" + fmt.getText() + "\"" // 生成警告信息，指出多余的参数
