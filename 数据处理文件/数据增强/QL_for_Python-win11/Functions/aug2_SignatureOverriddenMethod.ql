/**
 * @name Signature mismatch in overriding method
 * @description Detects methods that override a parent method but have incompatible signatures.
 *              Such mismatches can lead to runtime errors when the method is called with
 *              arguments expected by the parent but not accepted by the child, or vice versa.
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

// 查找重写方法时签名不匹配的情况
from FunctionValue parentMethod, PythonFunctionValue childMethod  // 从父类方法和子类方法中选择数据
where
  // 确保父类方法没有被调用
  not exists(parentMethod.getACall()) and
  // 确保没有其他子类方法重写了父类方法并且被调用
  not exists(FunctionValue otherChildMethod |
    otherChildMethod.overrides(parentMethod) and
    exists(otherChildMethod.getACall())
  ) and
  // 确保子类方法不是特殊方法或构造函数，并且是普通方法
  not childMethod.getScope().isSpecialMethod() and
  childMethod.getName() != "__init__" and
  childMethod.isNormalMethod() and
  // 检查子类方法是否重写了父类方法，并且参数数量不匹配
  childMethod.overrides(parentMethod) and
  (
    childMethod.minParameters() > parentMethod.maxParameters() or
    childMethod.maxParameters() < parentMethod.minParameters()
  )
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",  // 选择子类方法并生成警告信息
  parentMethod, "overridden method"  // 选择父类方法并标记为被重写的方法