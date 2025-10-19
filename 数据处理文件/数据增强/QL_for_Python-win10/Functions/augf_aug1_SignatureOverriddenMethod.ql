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
from FunctionValue baseMethod, PythonFunctionValue derivedMethod  // 从基类方法和派生类方法中选择数据
where
  // 验证基类方法未被直接调用
  not exists(baseMethod.getACall()) and
  // 确保没有其他派生类方法被调用
  not exists(FunctionValue siblingMethod |
    siblingMethod.overrides(baseMethod) and
    exists(siblingMethod.getACall())
  ) and
  // 检查派生类方法的基本特征
  (
    not derivedMethod.getScope().isSpecialMethod() and
    derivedMethod.getName() != "__init__" and
    derivedMethod.isNormalMethod()
  ) and
  // 确认重写关系
  derivedMethod.overrides(baseMethod) and
  // 检查参数签名不匹配条件
  (
    derivedMethod.minParameters() > baseMethod.maxParameters() or
    derivedMethod.maxParameters() < baseMethod.minParameters()
  )
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",  // 选择派生类方法并生成警告信息
  baseMethod, "overridden method"  // 选择基类方法并标记为被重写的方法