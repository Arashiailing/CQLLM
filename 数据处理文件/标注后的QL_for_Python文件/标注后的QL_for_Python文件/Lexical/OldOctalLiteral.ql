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

// 定义一个谓词函数，用于判断是否为旧式八进制字面量
predicate is_old_octal(IntegerLiteral i) {
  // 检查是否存在满足以下条件的字符串文本
  exists(string text | text = i.getText() |
    text.charAt(0) = "0" and // 第一个字符是'0'
    not text = "00" and // 排除掉"00"这种情况
    exists(text.charAt(1).toInt()) and // 第二个字符是一个数字
    /* Do not flag file permission masks */
    // 检查文本长度不是4、5或7（排除文件权限掩码）
    exists(int len | len = text.length() |
      len != 4 and
      len != 5 and
      len != 7
    )
  )
}

// 从所有整数字面量中选择符合条件的旧式八进制字面量
from IntegerLiteral i
where is_old_octal(i)
select i, "Confusing octal literal, use 0o" + i.getText().suffix(1) + " instead." // 选择并提示应使用0o前缀的八进制表示法
