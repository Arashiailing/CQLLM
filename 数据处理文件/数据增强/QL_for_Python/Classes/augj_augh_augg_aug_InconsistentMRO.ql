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

// 检测目标类是否存在无效方法解析顺序(MRO)
// 无效MRO发生在继承链中，右侧基类的不当超类型出现在其左侧位置
predicate hasInvalidMRO(ClassObject targetClass, ClassObject precedingBase, ClassObject followingBase) {
  // 验证目标类采用新式类定义
  targetClass.isNewStyle() and
  
  // 定位继承列表中相邻的基类对
  exists(int index | 
    index > 0 and 
    // 获取右侧基类及其直接左侧基类
    followingBase = targetClass.getBaseType(index) and 
    precedingBase = targetClass.getBaseType(index - 1)
  ) and
  
  // 确认左侧基类是右侧基类的不当超类型
  precedingBase = followingBase.getAnImproperSuperType()
}

// 识别所有具有无效方法解析顺序的类，并提供详细诊断信息
from ClassObject targetClass, ClassObject precedingBase, ClassObject followingBase
where hasInvalidMRO(targetClass, precedingBase, followingBase)
select targetClass,
  "Construction of class " + targetClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", precedingBase,
  precedingBase.getName(), followingBase, followingBase.getName()