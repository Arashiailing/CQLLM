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

// 查找所有在raise语句中使用NotImplemented的表达式
from Expr notImplementedExpr
where 
    // 检查表达式是否在raise语句中使用了NotImplemented
    use_of_not_implemented_in_raise(_, notImplementedExpr)
// 选择问题表达式并提供建议的修复信息
select notImplementedExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"