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
from FunctionValue parentMethod, PythonFunctionValue childMethod  // 从父类方法和子类方法中选择数据
where
  // 确保父类方法未被直接调用，且无其他重写子类方法被调用
  not exists(parentMethod.getACall()) and
  not exists(FunctionValue otherDerivedMethod |
    otherDerivedMethod.overrides(parentMethod) and
    exists(otherDerivedMethod.getACall())
  ) and
  // 验证子类方法符合基本方法特征
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  childMethod.isNormalMethod() and
  // 检查重写关系和参数不匹配条件
  childMethod.overrides(parentMethod) and
  (
    childMethod.minParameters() > parentMethod.maxParameters() or
    childMethod.maxParameters() < parentMethod.minParameters()
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",  // 选择子类方法并生成警告信息
  parentMethod, "overridden method"  // 选择父类方法并标记为被重写的方法