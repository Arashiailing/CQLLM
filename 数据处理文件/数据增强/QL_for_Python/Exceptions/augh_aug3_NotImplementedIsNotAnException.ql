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

// 导入Python基础分析库
import python

// 导入NotImplemented异常检测模块
import Exceptions.NotImplemented

// 查找所有在raise语句中误用NotImplemented的表达式
from Expr problematicExpr
where 
    // 检查表达式是否在raise上下文中使用了NotImplemented
    use_of_not_implemented_in_raise(_, problematicExpr)
// 输出问题表达式及修复建议
select problematicExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"