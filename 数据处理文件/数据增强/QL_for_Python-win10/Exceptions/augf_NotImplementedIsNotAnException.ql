/**
 * @name NotImplemented is not an Exception
 * @description Using 'NotImplemented' as an exception will result in a type error.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// 导入Python代码分析基础库
import python

// 导入NotImplemented异常相关模块
import Exceptions.NotImplemented

// 查找在raise语句中错误使用NotImplemented的表达式
from Expr problematicExpr
where use_of_not_implemented_in_raise(_, problematicExpr)

// 输出问题表达式并提示正确用法
select problematicExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"