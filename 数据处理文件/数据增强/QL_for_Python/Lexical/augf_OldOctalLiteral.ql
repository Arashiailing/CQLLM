/**
 * @name Confusing octal literal
 * @description Octal literal with a leading 0 is easily misread as a decimal value
 * @kind problem
 * @tags readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/old-style-octal-literal
 */

import python

// 定义谓词函数，用于识别旧式八进制字面量（以0开头但不包含0o前缀的八进制数）
predicate is_old_octal(IntegerLiteral literal) {
  exists(string literalText, int textLength |
    literalText = literal.getText() and
    textLength = literalText.length() and
    // 检查字面量以0开头，且不是特殊情况"00"
    literalText.charAt(0) = "0" and
    not literalText = "00" and
    // 确保第二个字符是数字（即这是一个有效的八进制数）
    exists(literalText.charAt(1).toInt()) and
    /* 排除文件权限掩码（通常为4、5或7位） */
    textLength != 4 and
    textLength != 5 and
    textLength != 7
  )
}

// 从所有整数字面量中筛选出旧式八进制字面量
from IntegerLiteral literal
where is_old_octal(literal)
select literal, "Confusing octal literal, use 0o" + literal.getText().suffix(1) + " instead."