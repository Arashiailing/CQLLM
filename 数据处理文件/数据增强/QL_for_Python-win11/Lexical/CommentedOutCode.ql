/**
 * @name Commented-out code
 * @description Commented-out code makes the remaining code more difficult to read.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code
 */

// 导入Python语言库
import python

// 导入Lexical模块中的CommentedOutCode类
import Lexical.CommentedOutCode

// 从CommentedOutCodeBlock类中选择c对象
from CommentedOutCodeBlock c
// 过滤条件：c不是示例代码
where not c.maybeExampleCode()
// 选择符合条件的c对象，并附加注释信息
select c, "This comment appears to contain commented-out code."
