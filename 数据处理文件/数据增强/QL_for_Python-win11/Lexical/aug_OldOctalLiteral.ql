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

// 判断整数字面量是否为旧式八进制表示法（以0开头）
predicate isLegacyOctalLiteral(IntegerLiteral literal) {
  exists(string literalText | literalText = literal.getText() |
    // 验证字面量以0开头，但排除"00"特殊情况
    literalText.charAt(0) = "0" and
    not literalText = "00" and
    
    // 确保第二个字符是数字（表示有效的八进制数）
    exists(literalText.charAt(1).toInt()) and
    
    /* 排除文件权限掩码的情况 */
    // 检查文本长度不是常见的文件权限掩码长度（4、5或7）
    exists(int textLength | textLength = literalText.length() |
      textLength != 4 and
      textLength != 5 and
      textLength != 7
    )
  )
}

// 查询所有使用旧式八进制表示法的整数字面量
from IntegerLiteral literal
where isLegacyOctalLiteral(literal)
select literal, "Confusing octal literal, use 0o" + literal.getText().suffix(1) + " instead."