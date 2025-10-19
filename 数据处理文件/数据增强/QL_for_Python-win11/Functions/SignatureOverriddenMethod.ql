/**
 * @name Signature mismatch in overriding method
 * @description Overriding a method without ensuring that both methods accept the same
 *              number and type of parameters has the potential to cause an error when there is a mismatch.
 * @kind problem
 * @problem.severity warning
 * @tags reliability
 *       correctness
 * @sub-severity high
 * @precision very-high
 * @id py/inheritance/signature-mismatch
 */

import python  // 导入Python库，用于分析Python代码
import Expressions.CallArgs  // 导入表达式调用参数模块

// 定义一个查询，查找在重写方法时签名不匹配的情况
from FunctionValue base, PythonFunctionValue derived  // 从基类函数和派生类函数中选择数据
where
  not exists(base.getACall()) and  // 确保基类函数没有被调用
  not exists(FunctionValue a_derived |
    a_derived.overrides(base) and  // 确保没有其他派生类函数重写了基类函数并且被调用
    exists(a_derived.getACall())
  ) and
  not derived.getScope().isSpecialMethod() and  // 确保派生类函数不是特殊方法
  derived.getName() != "__init__" and  // 确保派生类函数不是构造函数
  derived.isNormalMethod() and  // 确保派生类函数是普通方法
  // 为了效率，分布式检查重写情况
  (
    derived.overrides(base) and derived.minParameters() > base.maxParameters()  // 检查派生类函数的最小参数数量是否大于基类函数的最大参数数量
    or
    derived.overrides(base) and derived.maxParameters() < base.minParameters()  // 检查派生类函数的最大参数数量是否小于基类函数的最小参数数量
  )
select derived, "Overriding method '" + derived.getName() + "' has signature mismatch with $@.",  // 选择派生类函数并生成警告信息
  base, "overridden method"  // 选择基类函数并标记为被重写的方法
