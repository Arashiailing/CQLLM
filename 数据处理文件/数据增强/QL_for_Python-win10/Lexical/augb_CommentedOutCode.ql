/**
 * @name Commented-out code
 * @description Identifies code that has been commented out, which can reduce code readability and maintainability.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code
 */

// 引入必要的库和模块
import python
import Lexical.CommentedOutCode

// 定义查询：查找被注释掉的代码块
from CommentedOutCodeBlock commentedBlock
// 应用过滤条件：排除示例代码
where not commentedBlock.maybeExampleCode()
// 返回结果：被注释掉的代码块及其描述
select commentedBlock, "This comment appears to contain commented-out code."