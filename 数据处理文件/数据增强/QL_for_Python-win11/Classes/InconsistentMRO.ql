/**
 * @name Inconsistent method resolution order
 * @description Class definition will raise a type error at runtime due to inconsistent method resolution order(MRO)
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// 定义一个函数，用于获取类的左基类
ClassObject left_base(ClassObject type, ClassObject base) {
  // 存在一个整数i，使得i大于0且type的第i个基类等于base，并且返回type的第i-1个基类
  exists(int i | i > 0 and type.getBaseType(i) = base and result = type.getBaseType(i - 1))
}

// 定义一个谓词，用于判断是否存在无效的方法解析顺序（MRO）
predicate invalid_mro(ClassObject t, ClassObject left, ClassObject right) {
  // 检查t是否为新式类，并且left是t的基类之一，同时left是right的一个不适当的超类型
  t.isNewStyle() and
  left = left_base(t, right) and
  left = right.getAnImproperSuperType()
}

// 从所有类对象中选择那些具有无效MRO的类，并生成相应的警告信息
from ClassObject t, ClassObject left, ClassObject right
where invalid_mro(t, left, right)
select t,
  "Construction of class " + t.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", left,
  left.getName(), right, right.getName()
