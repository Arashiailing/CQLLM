/**
 * 分析特定类名和文件路径的类继承层次结构
 * 本查询用于识别目标类及其继承关系中的所有祖先类和后代类
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为所关注的目标类
predicate isClassOfInterest(Class targetClass) {
  // 检查类名是否与目标名称匹配
  targetClass.getName() = "YourClassName"
  // 可选：检查类是否位于特定文件路径
  // and targetClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的所有祖先类（包括直接和间接父类）
query predicate findAncestorClasses(Class descendantClass, Class ancestorClass) {
  isClassOfInterest(descendantClass) and
  ancestorClass = getADirectSuperclass+(descendantClass)
}

// 查询目标类的所有后代类（包括直接和间接子类）
query predicate findDescendantClasses(Class ancestorClass, Class descendantClass) {
  isClassOfInterest(ancestorClass) and
  descendantClass = getADirectSubclass+(ancestorClass)
}

// 选择所有符合条件的目标类
from Class classOfInterest
where isClassOfInterest(classOfInterest)
select classOfInterest