/**
 * 类继承层次结构深度分析
 * 此查询用于识别特定类及其完整继承链中的父类和子类关系
 * 支持分析直接/间接继承关系，提供类继承全景视图
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判定类是否符合分析目标条件
predicate isTargetClass(Class cls) {
  // 核心条件：匹配预设目标类名
  cls.getName() = "YourClassName"
  // 扩展条件：可按需启用文件路径限定
  // and cls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 递归获取目标类的所有祖先类（包括直接/间接父类）
query predicate getAllAncestorClasses(Class derivedCls, Class ancestorCls) {
  isTargetClass(derivedCls) and
  ancestorCls = getADirectSuperclass+(derivedCls)
}

// 递归获取目标类的所有后代类（包括直接/间接子类）
query predicate getAllDescendantClasses(Class baseCls, Class descendantCls) {
  isTargetClass(baseCls) and
  descendantCls = getADirectSubclass+(baseCls)
}

// 查询并输出所有符合目标条件的类实体
from Class analysisTarget
where isTargetClass(analysisTarget)
select analysisTarget