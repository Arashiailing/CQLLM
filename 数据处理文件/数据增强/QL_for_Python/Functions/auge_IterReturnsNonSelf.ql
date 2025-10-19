/**
 * @name Iterator does not return self from `__iter__` method
 * @description 迭代器的 `__iter__` 方法未返回自身实例，违反迭代器协议要求。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-self
 */

import python

// 获取指定类的 `__iter__` 方法定义
Function getIterMethod(ClassValue targetClass) { 
    result = targetClass.lookup("__iter__").(FunctionValue).getScope() 
}

// 检查值是否为函数的 'self' 参数
predicate isSelfReference(Name value, Function func) { 
    value.getVariable() = func.getArg(0).(Name).getVariable() 
}

// 检查函数是否未返回自身实例（包括无返回值或返回非self值）
predicate returnsNonSelfInstance(Function func) {
    // 情况1: 函数存在隐式返回（无显式return语句）
    exists(func.getFallthroughNode())
    // 情况2: 存在显式返回但值非self
    or
    exists(Return retNode | 
        retNode.getScope() = func and 
        not isSelfReference(retNode.getValue(), func)
    )
    // 情况3: 存在显式返回但无返回值（相当于返回None）
    or
    exists(Return retNode | 
        retNode.getScope() = func and 
        not exists(retNode.getValue())
    )
}

// 主查询逻辑
from ClassValue iteratorClass, Function iterMethod
where 
    // 确保目标类是迭代器
    iteratorClass.isIterator() and 
    // 获取该类的 `__iter__` 方法
    iterMethod = getIterMethod(iteratorClass) and 
    // 验证方法未返回自身实例
    returnsNonSelfInstance(iterMethod)
// 格式化输出结果
select iteratorClass, 
    "迭代器类 " + iteratorClass.getName() + " 的 $@ 方法未返回 'self' 实例", 
    iterMethod, iterMethod.getName()