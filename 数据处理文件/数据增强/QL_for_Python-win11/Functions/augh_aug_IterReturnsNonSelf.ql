/**
 * @name Iterator does not return self from `__iter__` method
 * @description 迭代器的 `__iter__` 方法未返回自身，违反 Python 迭代器协议
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-self
 */

import python

/**
 * 获取指定迭代器类中 `__iter__` 方法的作用域
 * @param targetClass - 待检查的迭代器类
 * @return - `__iter__` 方法的作用域
 */
Function getIterMethodScope(ClassValue targetClass) { 
    result = targetClass.lookup("__iter__").(FunctionValue).getScope() 
}

/**
 * 检查返回值是否为函数的首个参数（即 `self`）
 * @param retValue - 待检查的返回值
 * @param method - 包含该返回值的函数方法
 */
predicate isSelfReturn(Name retValue, Function method) { 
    retValue.getVariable() = method.getArg(0).(Name).getVariable() 
}

/**
 * 检查函数是否返回非自身或缺少返回值
 * @param method - 待检查的函数方法
 */
predicate returnsNonSelf(Function method) {
    // 情况1：函数存在 fallthrough 节点（无显式返回）
    exists(method.getFallthroughNode())
    or
    // 情况2：存在返回语句但返回值非自身或无返回值
    exists(Return retStmt | 
        retStmt.getScope() = method and 
        (
            not exists(retStmt.getValue())  // 无返回值
            or 
            not isSelfReturn(retStmt.getValue(), method)  // 返回值非自身
        )
    )
}

// 主查询：识别违反迭代器协议的类
from ClassValue iteratorClass, Function iterMethod
// 条件1：目标类是迭代器
where iteratorClass.isIterator() and 
      // 条件2：获取目标类的 `__iter__` 方法
      iterMethod = getIterMethodScope(iteratorClass) and 
      // 条件3：方法未正确返回自身
      returnsNonSelf(iterMethod)
// 输出结果：问题类、错误描述及问题方法
select iteratorClass, 
       "类 " + iteratorClass.getName() + " 作为迭代器但其 $@ 方法未返回 'self'",
       iterMethod, iterMethod.getName()