/**
 * 类继承层次结构分析
 * 此查询旨在识别特定类及其在继承体系中的完整父类和子类关系
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 确定类是否为当前分析的目标类
predicate isAnalysisTarget(Class targetClass) {
  // 检查类名是否与预设目标匹配
  targetClass.getName() = "YourClassName"
  // 可选条件：验证类是否位于特定文件路径
  // and targetClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 获取目标类的所有祖先类（包括直接和间接继承关系）
query predicate retrieveAncestorClasses(Class childClass, Class parentClass) {
  isAnalysisTarget(childClass) and
  parentClass = getADirectSuperclass+(childClass)
}

// 获取目标类的所有后代类（包括直接和间接派生关系）
query predicate retrieveDescendantClasses(Class parentClass, Class childClass) {
  isAnalysisTarget(parentClass) and
  childClass = getADirectSubclass+(parentClass)
}

// 检索并输出所有满足目标条件的类
from Class targetClass
where isAnalysisTarget(targetClass)
select targetClass