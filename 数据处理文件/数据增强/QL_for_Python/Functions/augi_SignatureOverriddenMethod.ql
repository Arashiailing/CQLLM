/**
 * @name 重写方法签名不匹配
 * @description 检测方法重写时参数签名不匹配的情况：派生类方法与基类方法接受的参数数量或类型不一致
 *              可能导致运行时错误
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

// 查找方法重写时签名不匹配的情况
from FunctionValue baseMethod, PythonFunctionValue derivedMethod
where
  // 确保基类方法未被调用
  not exists(baseMethod.getACall())
  and
  // 确保没有其他派生类方法重写基类方法且被调用
  not exists(FunctionValue otherDerivedMethod |
    otherDerivedMethod.overrides(baseMethod) and
    exists(otherDerivedMethod.getACall())
  )
  and
  // 验证派生类方法类型：非特殊方法、非构造函数且为普通方法
  not derivedMethod.getScope().isSpecialMethod() and
  derivedMethod.getName() != "__init__" and
  derivedMethod.isNormalMethod()
  and
  // 检查重写关系与参数数量不匹配
  derivedMethod.overrides(baseMethod) and
  (
    derivedMethod.minParameters() > baseMethod.maxParameters()  // 派生类最小参数数 > 基类最大参数数
    or
    derivedMethod.maxParameters() < baseMethod.minParameters()  // 派生类最大参数数 < 基类最小参数数
  )
select derivedMethod, "重写方法 '" + derivedMethod.getName() + "' 与 $@ 签名不匹配。", 
  baseMethod, "被重写的基类方法"