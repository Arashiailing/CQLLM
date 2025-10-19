/**
 * @name Assert statement tests the truth value of a literal constant
 * @description An assert statement testing a literal constant value may exhibit
 *              different behavior when optimizations are enabled.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/assert-literal-constant
 */

import python // 导入Python库，用于分析Python代码
import semmle.python.filters.Tests // 导入测试过滤器，用于排除测试用例中的断言

// 从Assert类中选择a和字符串值value
from Assert a, string value
where
  /* Exclude asserts inside test cases */
  not a.getScope().getScope*() instanceof TestScope and // 排除在测试用例范围内的断言
  exists(Expr test | test = a.getTest() | // 存在一个表达式test，它是断言的测试部分
    value = test.(IntegerLiteral).getN() // 如果test是整数字面量，则获取其值
    or
    value = "\"" + test.(StringLiteral).getS() + "\"" // 如果test是字符串字面量，则获取其值并加上引号
    or
    value = test.(NameConstant).toString() // 如果test是命名常量，则将其转换为字符串
  ) and
  /* Exclude asserts appearing at the end of a chain of `elif`s */
  not exists(If i | i.getElif().getAnOrelse() = a) // 排除出现在一系列`elif`语句末尾的断言
select a, "Assert of literal constant " + value + "." // 选择断言a和对应的字面量常量值的描述信息
