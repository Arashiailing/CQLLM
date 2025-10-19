/**
 * @name 类构造函数参数数量不匹配
 * @description 检测类实例化时传递给 `__init__` 方法的参数数量与定义不符的情况，
 *              这会在运行时引发 TypeError 异常。
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-685
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-number-class-arguments
 */

import python
import Expressions.CallArgs

from Call callSite, ClassValue targetClass, string issueType, string limitText, int expectedCount, FunctionValue classInitializer
where
  // 获取目标类的初始化方法（__init__或构造函数）
  classInitializer = get_function_or_initializer(targetClass) and
  (
    // 处理参数过多的情况
    too_many_args(callSite, targetClass, expectedCount) and
    issueType = "too many arguments" and
    limitText = "no more than "
    or
    // 处理参数过少的情况
    too_few_args(callSite, targetClass, expectedCount) and
    issueType = "too few arguments" and
    limitText = "no fewer than "
  )
select callSite, 
  "Call to $@ with " + issueType + "; should be " + limitText + expectedCount.toString() + ".", 
  classInitializer,
  // 输出调用点、错误消息及初始化方法的完全限定名
  classInitializer.getQualifiedName()