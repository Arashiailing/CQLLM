/**
 * @name Maybe undefined class attribute
 * @description Accessing an attribute of `self` that is not initialized in the `__init__` method may cause an AttributeError at runtime
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision low
 * @id py/maybe-undefined-attribute
 */

import python
import ClassAttributes

// 定义一个谓词，用于检查属性是否由其他属性保护
predicate guarded_by_other_attribute(SelfAttributeRead a, CheckClass c) {
  // 检查类c有时定义了属性a的名称
  c.sometimesDefines(a.getName()) and
  // 存在一个属性guard，如果条件i包含a并且类c在初始化时分配了guard的名称
  exists(SelfAttributeRead guard, If i |
    i.contains(a) and
    c.assignedInInit(guard.getName())
  |
    // 条件i的测试部分等于guard或包含guard
    i.getTest() = guard
    or
    i.getTest().contains(guard)
  )
}

// 定义另一个谓词，用于检查属性可能未定义的情况
predicate maybe_undefined_class_attribute(SelfAttributeRead a, CheckClass c) {
  // 检查类c有时定义了属性a的名称
  c.sometimesDefines(a.getName()) and
  // 检查类c没有总是定义属性a的名称
  not c.alwaysDefines(a.getName()) and
  // 检查属性a是有趣的未定义状态
  c.interestingUndefined(a) and
  // 检查属性a没有被其他属性保护
  not guarded_by_other_attribute(a, c)
}

// 从属性a、类对象c和属性存储sa中选择数据
from Attribute a, ClassObject c, SelfAttributeStore sa
where
  // 检查属性a可能未定义且符合条件
  maybe_undefined_class_attribute(a, c) and
  // 检查属性存储sa的类与类对象c的类匹配
  sa.getClass() = c.getPyClass() and
  // 检查属性存储sa的名称与属性a的名称匹配
  sa.getName() = a.getName()
select a,
  // 输出警告信息，指出属性a未在类体或__init__方法中定义，但在某处定义了
  "Attribute '" + a.getName() +
    "' is not defined in the class body nor in the __init__() method, but it is defined $@.", sa,
  // 指示位置
  "here"
