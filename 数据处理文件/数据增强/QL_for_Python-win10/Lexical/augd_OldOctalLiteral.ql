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

// 谓词函数：识别旧式八进制字面量（以0开头，但不是0o前缀的形式）
predicate is_old_octal(IntegerLiteral literal) {
  exists(string literalText | literalText = literal.getText() |
    // 旧式八进制字面量必须以'0'开头
    literalText.charAt(0) = "0" and
    // 排除特殊情况："00"不被视为旧式八进制字面量
    not literalText = "00" and
    // 确保第二个字符存在且是一个数字
    exists(literalText.charAt(1).toInt()) and
    /* 忽略文件权限掩码（通常长度为4、5或7） */
    exists(int textLength | textLength = literalText.length() |
      textLength != 4 and
      textLength != 5 and
      textLength != 7
    )
  )
}

// 查询所有旧式八进制字面量并提供建议
from IntegerLiteral literal
where is_old_octal(literal)
select literal, "Confusing octal literal, use 0o" + literal.getText().suffix(1) + " instead." // 建议使用0o前缀的现代八进制表示法