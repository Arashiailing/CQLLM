/**
 * @name Undefined class attribute
 * @description Accessing an attribute of `self` that is not initialized anywhere in the class in the `__init__` method may cause an AttributeError at runtime
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision low
 * @id py/undefined-attribute
 */

import python
import ClassAttributes

// 定义一个谓词函数，用于检查未定义的类属性
predicate undefined_class_attribute(SelfAttributeRead a, CheckClass c, int line, string name) {
  // 获取属性名称
  name = a.getName() and
  // 检查该属性是否在类中有时被定义
  not c.sometimesDefines(name) and
  // 检查该属性是否是有趣的未定义属性
  c.interestingUndefined(a) and
  // 获取属性访问的行号
  line = a.getLocation().getStartLine() and
  // 检查该属性是否在初始化方法中被赋值
  not attribute_assigned_in_method(c.getAMethodCalledFromInit(), name)
}

// 定义一个报告未定义类属性的谓词函数
predicate report_undefined_class_attribute(Attribute a, ClassObject c, string name) {
  // 存在一个行号，使得未定义的类属性条件成立，并且是最小的行号
  exists(int line |
    undefined_class_attribute(a, c, line, name) and
    line = min(int x | undefined_class_attribute(_, c, x, name))
  )
}

// 从所有属性和类对象中选择满足条件的未定义类属性，并生成报告
from Attribute a, ClassObject c, string name
where report_undefined_class_attribute(a, c, name)
select a, "Attribute '" + name + "' is not defined in either the class body or in any method."
