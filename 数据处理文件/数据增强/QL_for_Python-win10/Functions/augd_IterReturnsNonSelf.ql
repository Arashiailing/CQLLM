/**
 * @name Iterator does not return self from `__iter__` method
 * @description 迭代器的 `__iter__` 方法没有返回自身，违反了迭代器协议。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-self
 */

import python

// 获取类的 `__iter__` 方法的作用域
Function getIterMethod(ClassValue iteratorClass) { 
    result = iteratorClass.lookup("__iter__").(FunctionValue).getScope() 
}

// 检查返回的值是否是函数的第一个参数（即 self）
predicate isSelfReturn(Name value, Function iterMethod) { 
    value.getVariable() = iterMethod.getArg(0).(Name).getVariable() 
}

// 检查函数是否返回非自身或没有返回值
predicate returnsNonSelf(Function iterMethod) {
    // 检查函数是否有 fallthrough 节点（即没有显式返回）
    exists(iterMethod.getFallthroughNode())
    // 或者函数有返回语句，但返回的值不是自身
    or
    exists(Return r | 
        r.getScope() = iterMethod and 
        not isSelfReturn(r.getValue(), iterMethod)
    )
    // 或者函数有返回语句，但没有返回值
    or
    exists(Return r | 
        r.getScope() = iterMethod and 
        not exists(r.getValue())
    )
}

// 查找所有迭代器类，其 `__iter__` 方法没有返回 self
from ClassValue iteratorClass, Function iterMethod
where 
    iteratorClass.isIterator() and 
    iterMethod = getIterMethod(iteratorClass) and 
    returnsNonSelf(iterMethod)
select iteratorClass, 
    "Class " + iteratorClass.getName() + " is an iterator but its $@ method does not return 'self'.",
    iterMethod, iterMethod.getName()