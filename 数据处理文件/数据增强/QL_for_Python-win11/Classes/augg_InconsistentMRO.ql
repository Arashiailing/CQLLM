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

// 获取指定类的直接左基类
// 该函数检查类继承列表中的位置关系，返回给定基类左侧的基类
ClassObject getLeftBaseClass(ClassObject type, ClassObject base) {
  // 存在一个正整数索引i，使得type的第i个基类等于base，返回其左侧相邻的基类
  exists(int i | i > 0 and type.getBaseType(i) = base and result = type.getBaseType(i - 1))
}

// 判断类是否具有无效的方法解析顺序(MRO)
// 当左基类同时是右基类的不适当超类型时，会导致MRO不一致
predicate hasInvalidMethodResolutionOrder(ClassObject cls, ClassObject leftBase, ClassObject rightBase) {
  // 检查类是否为新式类，获取基类关系，并验证MRO一致性
  cls.isNewStyle() and
  leftBase = getLeftBaseClass(cls, rightBase) and
  leftBase = rightBase.getAnImproperSuperType()
}

// 查询所有具有无效MRO的类，并报告错误
from ClassObject cls, ClassObject leftBase, ClassObject rightBase
where hasInvalidMethodResolutionOrder(cls, leftBase, rightBase)
select cls,
  "Construction of class " + cls.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", leftBase,
  leftBase.getName(), rightBase, rightBase.getName()