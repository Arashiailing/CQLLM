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

// 导入Python库，用于分析Python代码
import python

// 导入NotImplemented异常类
import Exceptions.NotImplemented

// 从Expr表达式中选择notimpl变量
from Expr notimpl
// 使用where子句过滤出在raise语句中使用NotImplemented的情况
where use_of_not_implemented_in_raise(_, notimpl)
// 选择notimpl变量并生成警告信息
select notimpl, "NotImplemented is not an Exception. Did you mean NotImplementedError?"
