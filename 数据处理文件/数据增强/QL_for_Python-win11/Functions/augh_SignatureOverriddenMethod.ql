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

import python  // 导入Python库，用于分析Python代码
import Expressions.CallArgs  // 导入表达式调用参数模块

// 定义查询，用于检测方法重写时的签名不匹配问题
from FunctionValue baseFunction, PythonFunctionValue derivedFunction  // 从基类函数和派生类函数中选择数据
where
  // 确保基类函数没有被直接调用
  not exists(baseFunction.getACall()) and
  
  // 确保没有其他派生类函数重写了基类函数并且被调用
  not exists(FunctionValue otherDerived |
    otherDerived.overrides(baseFunction) and
    exists(otherDerived.getACall())
  ) and
  
  // 排除特殊方法和构造函数
  not derivedFunction.getScope().isSpecialMethod() and
  derivedFunction.getName() != "__init__" and
  
  // 确保派生类函数是普通方法
  derivedFunction.isNormalMethod() and
  
  // 检查派生类函数是否重写了基类函数，并且参数数量不匹配
  derivedFunction.overrides(baseFunction) and
  (
    // 派生类函数的最小参数数量大于基类函数的最大参数数量
    derivedFunction.minParameters() > baseFunction.maxParameters()
    or
    // 派生类函数的最大参数数量小于基类函数的最小参数数量
    derivedFunction.maxParameters() < baseFunction.minParameters()
  )

// 选择派生类函数并生成警告信息，同时标记基类函数为被重写的方法
select derivedFunction, 
  "Overriding method '" + derivedFunction.getName() + "' has signature mismatch with $@.",
  baseFunction, "overridden method"