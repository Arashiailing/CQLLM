/**
 * @name Signature mismatch in overriding method
 * @description Detects methods that override parent class methods but have incompatible
 *              parameter signatures, which can lead to runtime errors when the methods are called.
 * @kind problem
 * @problem.severity warning
 * @tags reliability
 *       correctness
 * @sub-severity high
 * @precision very-high
 * @id py/inheritance/signature-mismatch
 */

import python  // 导入Python分析库，提供Python代码分析的基础功能
import Expressions.CallArgs  // 导入表达式调用参数处理模块，用于分析函数调用参数

// 查询定义：识别子类重写父类方法时签名不匹配的情况
from FunctionValue parentMethod, PythonFunctionValue childMethod  // 从父类方法和子类方法中选取数据源
where
  // 确保父类方法未被调用，避免误报已使用的方法
  not exists(parentMethod.getACall()) and
  
  // 检查是否有其他子类方法重写了同一个父类方法且被调用
  not exists(FunctionValue anotherDerivedMethod |
    anotherDerivedMethod.overrides(parentMethod) and  // 确认重写关系
    exists(anotherDerivedMethod.getACall())  // 确认被调用
  ) and
  
  // 排除特殊方法和构造函数，专注于普通业务方法
  not childMethod.getScope().isSpecialMethod() and  // 不是特殊方法
  childMethod.getName() != "__init__" and  // 不是构造函数
  childMethod.isNormalMethod() and  // 确保是普通方法
  
  // 确认重写关系并检查参数数量不匹配的情况
  childMethod.overrides(parentMethod) and
  (
    // 情况1：子类方法所需的最小参数多于父类方法能接受的最大参数
    childMethod.minParameters() > parentMethod.maxParameters()
    or
    // 情况2：子类方法能接受的最大参数少于父类方法所需的最小参数
    childMethod.maxParameters() < parentMethod.minParameters()
  )

// 输出结果：子类方法及其相关的警告信息
select childMethod, "Overriding method '" + childMethod.getName() + "' has signature mismatch with $@.",  // 选择子类方法并生成警告消息
  parentMethod, "overridden method"  // 选择父类方法并标记为被重写的方法