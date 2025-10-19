/**
 * @name Implicit string concatenation in a list
 * @description Omitting a comma between strings causes implicit concatenation which is confusing in a list.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       convention
 *       external/cwe/cwe-665
 * @problem.severity warning
 * @sub-severity high
 * @precision high
 * @id py/implicit-string-concatenation-in-list
 */

import python

// 定义一个谓词函数，用于判断表达式是否为字符串常量或由字符串常量隐式连接组成。
predicate string_const(Expr s) {
  // 检查表达式是否是字符串字面量。
  s instanceof StringLiteral
  // 或者递归检查二元表达式的左右部分是否都是字符串常量。
  or
  string_const(s.(BinaryExpr).getLeft()) and string_const(s.(BinaryExpr).getRight())
}

// 从字符串字面量开始查询。
from StringLiteral s
where
  // 隐式连接的字符串在列表中，并且该列表至少包含另一个字符串。
  exists(List l, Expr other |
    // 确保当前字符串与其他字符串不同。
    not s = other and
    // 列表中包含当前字符串。
    l.getAnElt() = s and
    // 列表中包含其他字符串。
    l.getAnElt() = other and
    // 其他字符串也是字符串常量。
    string_const(other)
  ) and
  // 存在隐式连接的部分。
  exists(s.getAnImplicitlyConcatenatedPart()) and
  // 当前字符串没有被括号包围。
  not s.isParenthesized()
select s, "Implicit string concatenation. Maybe missing a comma?"
