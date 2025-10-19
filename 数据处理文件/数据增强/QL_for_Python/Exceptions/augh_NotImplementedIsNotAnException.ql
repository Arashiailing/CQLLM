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

// 导入Python基础分析库，提供Python代码分析的核心功能
import python

// 导入NotImplemented异常处理模块，用于检测NotImplemented的错误使用模式
import Exceptions.NotImplemented

// 查询目标：识别所有在raise语句中错误使用NotImplemented的表达式
from Expr notImplementedExpr
// 筛选条件：检查表达式是否在raise语句中被用作NotImplemented
// use_of_not_implemented_in_raise谓词用于捕获这种特定的错误使用模式
where use_of_not_implemented_in_raise(_, notImplementedExpr)
// 输出结果：报告问题位置并提供修复建议
select notImplementedExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"