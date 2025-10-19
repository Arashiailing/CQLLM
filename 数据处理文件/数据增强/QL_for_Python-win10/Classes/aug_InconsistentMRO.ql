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

// 获取指定基类在继承列表中的左侧相邻基类
ClassObject getLeftBase(ClassObject cls, ClassObject baseClass) {
  // 存在位置索引index，使index>0且cls的第index个基类是baseClass，返回第index-1个基类
  exists(int index | 
    index > 0 and 
    cls.getBaseType(index) = baseClass and 
    result = cls.getBaseType(index - 1)
  )
}

// 检测类是否存在无效的方法解析顺序
predicate hasInvalidMRO(ClassObject targetClass, ClassObject leftBase, ClassObject rightBase) {
  // 验证目标类是新式类，且leftBase是rightBase的不当超类型
  targetClass.isNewStyle() and
  leftBase = getLeftBase(targetClass, rightBase) and
  leftBase = rightBase.getAnImproperSuperType()
}

// 查询所有存在无效MRO的类并生成诊断信息
from ClassObject targetClass, ClassObject leftBase, ClassObject rightBase
where hasInvalidMRO(targetClass, leftBase, rightBase)
select targetClass,
  "Construction of class " + targetClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", leftBase,
  leftBase.getName(), rightBase, rightBase.getName()