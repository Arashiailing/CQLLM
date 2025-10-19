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

// 检测目标类是否存在无效的方法解析顺序（MRO）
// 当继承列表中某个基类（rightBase）的左侧基类（leftBase）是其不当超类型时触发
predicate hasInvalidMRO(ClassObject targetClass, ClassObject leftBase, ClassObject rightBase) {
  // 验证目标类是新式类
  targetClass.isNewStyle() and
  // 查找继承列表中rightBase左侧的基类
  exists(int position | 
    position > 0 and 
    targetClass.getBaseType(position) = rightBase and 
    leftBase = targetClass.getBaseType(position - 1)
  ) and
  // 验证左侧基类是右侧基类的不当超类型
  leftBase = rightBase.getAnImproperSuperType()
}

// 查询所有存在无效MRO的类并生成诊断信息
from ClassObject targetClass, ClassObject leftBase, ClassObject rightBase
where hasInvalidMRO(targetClass, leftBase, rightBase)
select targetClass,
  "Construction of class " + targetClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", leftBase,
  leftBase.getName(), rightBase, rightBase.getName()