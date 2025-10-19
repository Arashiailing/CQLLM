/**
 * @name Commented-out code
 * @description Identifies code segments that have been commented out, which can reduce code readability and maintainability.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

// 导入Python语言分析库以支持静态代码分析
import python

// 导入Lexical.CommentedOutCode模块用于检测注释掉的代码片段
import Lexical.CommentedOutCode

// 查询所有被注释掉的代码块，排除可能是示例代码的情况
from CommentedOutCodeBlock commentedCode
where not commentedCode.maybeExampleCode()
// 输出结果：注释代码块位置和描述信息
select commentedCode, "This comment appears to contain commented-out code."