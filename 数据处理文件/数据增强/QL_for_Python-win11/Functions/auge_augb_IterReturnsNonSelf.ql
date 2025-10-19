/**
 * @name Iterator does not return self from `__iter__` method
 * @description 检测迭代器类的 `__iter__` 方法未返回自身实例的情况，违反Python迭代器协议要求
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-self
 */

import python

// 获取迭代器类的 `__iter__` 方法实现
Function getIterMethod(ClassValue iterClass) { 
  result = iterClass.lookup("__iter__").(FunctionValue).getScope() 
}

// 判断变量是否为函数的 `self` 参数
predicate isSelfReference(Name varNode, Function method) { 
  varNode.getVariable() = method.getArg(0).(Name).getVariable() 
}

// 检测迭代器方法是否违反返回协议
predicate violatesReturnProtocol(Function method) {
  // 情况1: 方法存在未显式返回的执行路径
  exists(method.getFallthroughNode())
  or
  // 情况2: 存在返回语句但未返回值（隐式返回None）
  exists(Return returnStmt | 
    returnStmt.getScope() = method and 
    not exists(returnStmt.getValue())
  )
  or
  // 情况3: 存在返回语句但返回值非self
  exists(Return returnStmt | 
    returnStmt.getScope() = method and 
    exists(returnStmt.getValue()) and 
    not isSelfReference(returnStmt.getValue(), method)
  )
}

// 查找违反迭代器协议的类
from ClassValue iterClass, Function iterFunc
where 
  // 确保是迭代器类
  iterClass.isIterator() and 
  // 获取类的__iter__方法
  iterFunc = getIterMethod(iterClass) and 
  // 检查方法是否违反返回协议
  violatesReturnProtocol(iterFunc)
// 输出检测结果
select iterClass, 
  "迭代器类 " + iterClass.getName() + " 的 $@ 方法未返回 'self' 实例，违反迭代器协议。",
  iterFunc, iterFunc.getName()