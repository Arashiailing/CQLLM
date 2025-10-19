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

// 定义谓词函数，用于检测传统风格的八进制字面量（以0开头但没有0o前缀的八进制数）
predicate isLegacyOctalLiteral(IntegerLiteral octalLiteral) {
  exists(string literalValue, int valueLength |
    literalValue = octalLiteral.getText() and
    valueLength = literalValue.length() and
    // 验证字面量以0开头，且排除特殊情况"00"
    literalValue.charAt(0) = "0" and
    not literalValue = "00" and
    // 确保第二个字符是有效的数字（表示这是一个合法的八进制数）
    exists(literalValue.charAt(1).toInt()) and
    /* 过滤掉常见的文件权限掩码格式（通常为4、5或7位长度） */
    not (valueLength = 4 or valueLength = 5 or valueLength = 7)
  )
}

// 查找所有符合传统八进制字面量特征的整数字面量
from IntegerLiteral octalLiteral
where isLegacyOctalLiteral(octalLiteral)
select octalLiteral, "Confusing octal literal, use 0o" + octalLiteral.getText().suffix(1) + " instead."