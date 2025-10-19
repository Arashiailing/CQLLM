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

/**
 * 判断整数字面量是否为旧式八进制表示法（以0开头但非0o前缀）
 * 这种表示法容易与十进制混淆，建议使用明确的0o前缀表示法
 */
predicate is_old_style_octal_literal(IntegerLiteral intLiteral) {
  exists(string literalText | literalText = intLiteral.getText() |
    // 必须以'0'开头，但排除"00"特殊情况
    literalText.charAt(0) = "0" and
    not literalText = "00" and
    // 确保第二个字符是数字（0-7）
    exists(literalText.charAt(1).toInt()) and
    /* 排除文件权限掩码，它们通常具有特定长度 */
    exists(int textLength | textLength = literalText.length() |
      textLength != 4 and  // 如 0755
      textLength != 5 and  // 如 00755
      textLength != 7     // 如 0000755
    )
  )
}

// 查找所有使用旧式八进制表示的整数字面量
from IntegerLiteral octalLiteral
where is_old_style_octal_literal(octalLiteral)
select octalLiteral, 
  "Confusing octal literal, use 0o" + octalLiteral.getText().suffix(1) + " instead."