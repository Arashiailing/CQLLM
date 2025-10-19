/**
 * 分析类继承层次结构关系
 * 本查询用于识别特定类及其在继承体系中的所有父类和子类关系
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为分析目标类
predicate isTargetClass(Class subjectCls) {
  // 检查类名是否匹配预设目标
  subjectCls.getName() = "YourClassName"
  // 可选条件：验证类是否位于特定文件路径
  // and subjectCls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的所有父类（包括直接和间接继承关系）
query predicate getSuperClasses(Class derivedCls, Class baseCls) {
  isTargetClass(derivedCls) and
  baseCls = getADirectSuperclass+(derivedCls)
}

// 查询目标类的所有子类（包括直接和间接派生关系）
query predicate getSubClasses(Class baseCls, Class derivedCls) {
  isTargetClass(baseCls) and
  derivedCls = getADirectSubclass+(baseCls)
}

// 查询并返回所有符合目标条件的类
from Class subjectCls
where isTargetClass(subjectCls)
select subjectCls