/**
 * @name Signature mismatch in overriding method
 * @description Detects when a method overrides another method with incompatible parameter counts,
 *              which may lead to runtime errors due to signature mismatches.
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

// 查找重写方法中参数签名不匹配的情况
from FunctionValue parentFunction, PythonFunctionValue childFunction  // 从基类方法和派生类方法中选择数据
where
  // 验证基类方法未被直接调用
  not exists(parentFunction.getACall()) and
  // 确保没有其他派生类方法被调用
  not exists(FunctionValue siblingOverride |
    siblingOverride.overrides(parentFunction) and
    exists(siblingOverride.getACall())
  ) and
  // 检查派生类方法的基本特征
  (
    not childFunction.getScope().isSpecialMethod() and
    childFunction.getName() != "__init__" and
    childFunction.isNormalMethod()
  ) and
  // 确认重写关系
  childFunction.overrides(parentFunction) and
  // 检查参数签名不匹配条件
  (
    childFunction.minParameters() > parentFunction.maxParameters() or
    childFunction.maxParameters() < parentFunction.minParameters()
  )
select childFunction, "Overriding method '" + childFunction.getName() + "' has signature mismatch with $@.",  // 选择派生类方法并生成警告信息
  parentFunction, "overridden method"  // 选择基类方法并标记为被重写的方法