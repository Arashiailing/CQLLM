/**
 * @name Iterator does not return self from `__iter__` method
 * @description 迭代器的 `__iter__` 方法未返回自身实例，违反了Python迭代器协议要求。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-self
 */

import python

// 获取指定迭代器类的 `__iter__` 方法实现
Function getIterMethod(ClassValue iteratorClass) { 
  result = iteratorClass.lookup("__iter__").(FunctionValue).getScope() 
}

// 检查变量是否为函数的 `self` 参数
predicate isSelfReference(Name variableNode, Function func) { 
  variableNode.getVariable() = func.getArg(0).(Name).getVariable() 
}

// 检查迭代器方法是否违反返回协议
predicate violatesReturnProtocol(Function func) {
  // 情况1: 方法存在未显式返回的执行路径
  exists(func.getFallthroughNode())
  or
  // 情况2: 存在返回语句但未返回值（隐式返回None）
  exists(Return retNode | 
    retNode.getScope() = func and 
    not exists(retNode.getValue())
  )
  or
  // 情况3: 存在返回语句但返回值非self
  exists(Return retNode | 
    retNode.getScope() = func and 
    exists(retNode.getValue()) and 
    not isSelfReference(retNode.getValue(), func)
  )
}

// 查找违反迭代器协议的类
from ClassValue iteratorClass, Function iterMethod
where 
  // 确保是迭代器类
  iteratorClass.isIterator() and 
  // 获取类的__iter__方法
  iterMethod = getIterMethod(iteratorClass) and 
  // 检查方法是否违反返回协议
  violatesReturnProtocol(iterMethod)
// 输出检测结果
select iteratorClass, 
  "迭代器类 " + iteratorClass.getName() + " 的 $@ 方法未返回 'self' 实例，违反迭代器协议。",
  iterMethod, iterMethod.getName()