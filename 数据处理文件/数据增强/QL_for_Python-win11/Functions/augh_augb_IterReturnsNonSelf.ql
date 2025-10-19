/**
 * @name Iterator does not return self from `__iter__` method
 * @description 检测迭代器类的 `__iter__` 方法是否返回了自身实例，符合Python迭代器协议要求。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-self
 */

import python

// 提取迭代器类中的 `__iter__` 方法实现
Function extractIterMethod(ClassValue iterClass) { 
  result = iterClass.lookup("__iter__").(FunctionValue).getScope() 
}

// 判断变量是否为方法的 `self` 参数
predicate isSelfParameter(Name varNode, Function method) { 
  varNode.getVariable() = method.getArg(0).(Name).getVariable() 
}

// 检查方法是否有未显式返回的执行路径
predicate hasImplicitReturn(Function method) {
  exists(method.getFallthroughNode())
}

// 检查方法是否存在无返回值的返回语句
predicate hasEmptyReturn(Function method) {
  exists(Return returnStmt | 
    returnStmt.getScope() = method and 
    not exists(returnStmt.getValue())
  )
}

// 检查方法是否存在返回非self值的返回语句
predicate hasNonSelfReturn(Function method) {
  exists(Return returnStmt | 
    returnStmt.getScope() = method and 
    exists(returnStmt.getValue()) and 
    not isSelfParameter(returnStmt.getValue(), method)
  )
}

// 判断迭代器方法是否违反了返回协议
predicate violatesIterProtocol(Function method) {
  hasImplicitReturn(method) or
  hasEmptyReturn(method) or
  hasNonSelfReturn(method)
}

// 查找违反迭代器协议的类
from ClassValue iterClass, Function iterMethodImpl
where 
  // 确保类实现了迭代器协议
  iterClass.isIterator() and 
  // 获取类的__iter__方法实现
  iterMethodImpl = extractIterMethod(iterClass) and 
  // 检查方法是否违反返回协议
  violatesIterProtocol(iterMethodImpl)
// 输出检测结果
select iterClass, 
  "迭代器类 " + iterClass.getName() + " 的 $@ 方法未返回 'self' 实例，违反迭代器协议。",
  iterMethodImpl, iterMethodImpl.getName()