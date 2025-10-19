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

// 判断给定类是否具有无效的方法解析顺序
// 此情况发生在继承链中，右侧基类的不当超类型出现在其左侧位置
predicate hasInvalidMRO(ClassObject cls, ClassObject precedingBase, ClassObject followingBase) {
  // 确保目标类采用新式类定义
  cls.isNewStyle() and
  // 定位继承列表中右侧基类及其直接左侧的基类
  exists(int idx | 
    idx > 0 and 
    cls.getBaseType(idx) = followingBase and 
    precedingBase = cls.getBaseType(idx - 1)
  ) and
  // 验证左侧基类与右侧基类存在不当的超类型关系
  precedingBase = followingBase.getAnImproperSuperType()
}

// 识别所有具有无效方法解析顺序的类，并提供详细诊断
from ClassObject cls, ClassObject precedingBase, ClassObject followingBase
where hasInvalidMRO(cls, precedingBase, followingBase)
select cls,
  "Construction of class " + cls.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", precedingBase,
  precedingBase.getName(), followingBase, followingBase.getName()