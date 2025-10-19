/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description Descriptor objects can be shared across many instances. Mutating them can cause strange side effects or race conditions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// 定义一个谓词函数，用于判断类对象是否在描述符方法中发生变异
predicate mutates_descriptor(ClassObject cls, SelfAttributeStore s) {
  // 检查类对象是否为描述符类型
  cls.isDescriptorType() and
  // 存在一个函数对象f和一个getter或setter方法
  exists(PyFunctionObject f, PyFunctionObject get_set |
    // 检查类对象是否有名为__get__、__set__或__delete__的属性
    exists(string name | cls.lookupAttribute(name) = get_set |
      name = "__get__" or name = "__set__" or name = "__delete__"
    ) and
    // 查找类对象中的方法并确保其与函数对象f匹配
    cls.lookupAttribute(_) = f and
    // 确保getter或setter方法调用了函数对象f
    get_set.getACallee*() = f and
    // 排除初始化方法__init__
    not f.getName() = "__init__" and
    // 确保变异发生在函数对象的范围内
    s.getScope() = f.getFunction()
  )
}

// 从类对象和属性存储中选择数据
from ClassObject cls, SelfAttributeStore s
// 条件是mutates_descriptor谓词函数返回真
where mutates_descriptor(cls, s)
// 选择属性存储、问题描述、类对象及其名称
select s,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  cls, cls.getName()
