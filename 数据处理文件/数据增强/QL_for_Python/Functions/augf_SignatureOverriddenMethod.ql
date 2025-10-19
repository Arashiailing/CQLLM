/**
 * @name Signature mismatch in overriding method
 * @description Detects when a method overrides another method but has a different signature,
 *              which can lead to runtime errors due to parameter count or type mismatches.
 * @kind problem
 * @problem.severity warning
 * @tags reliability
 *       correctness
 * @sub-severity high
 * @precision very-high
 * @id py/inheritance/signature-mismatch
 */

import python
import Expressions.CallArgs

// 查找在子类中重写父类方法时签名不匹配的情况
from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // 确保父类方法没有被调用
  not exists(baseMethod.getACall()) and
  // 确保没有其他子类方法重写了父类方法并且被调用
  not exists(FunctionValue otherDerivedMethod |
    otherDerivedMethod.overrides(baseMethod) and
    exists(otherDerivedMethod.getACall())
  ) and
  // 过滤掉特殊方法和构造函数
  not derivedMethod.getScope().isSpecialMethod() and
  derivedMethod.getName() != "__init__" and
  derivedMethod.isNormalMethod() and
  // 为了效率，分布式检查重写情况
  (
    derivedMethod.overrides(baseMethod) and derivedMethod.minParameters() > baseMethod.maxParameters() or
    derivedMethod.overrides(baseMethod) and derivedMethod.maxParameters() < baseMethod.minParameters()
  )
select derivedMethod, "Overriding method '" + derivedMethod.getName() + "' has signature mismatch with $@.",
  baseMethod, "overridden method"