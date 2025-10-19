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

// 获取指定基类在继承列表中的前一个基类
ClassObject preceding_base(ClassObject targetClass, ClassObject baseClass) {
  exists(int index | 
    index > 0 and 
    targetClass.getBaseType(index) = baseClass and 
    result = targetClass.getBaseType(index - 1)
  )
}

// 检测类是否存在无效的方法解析顺序
predicate has_invalid_mro(ClassObject targetClass, ClassObject leftBase, ClassObject rightBase) {
  targetClass.isNewStyle() and
  leftBase = preceding_base(targetClass, rightBase) and
  leftBase = rightBase.getAnImproperSuperType()
}

// 查询所有具有无效MRO的类并生成警告
from ClassObject targetClass, ClassObject leftBase, ClassObject rightBase
where has_invalid_mro(targetClass, leftBase, rightBase)
select targetClass,
  "Construction of class " + targetClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", leftBase,
  leftBase.getName(), rightBase, rightBase.getName()