/**
 * 类继承层次结构分析
 * 本查询识别目标类及其在继承体系中的所有父类和子类关系
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为目标分析类
predicate isTargetClass(Class targetClass) {
  // 验证类名匹配预设目标
  targetClass.getName() = "YourClassName"
  // 可选条件：验证类是否位于特定文件路径
  // and targetClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的所有父类（直接和间接继承关系）
query predicate getParentClasses(Class childClass, Class parentClass) {
  isTargetClass(childClass) and
  parentClass = getADirectSuperclass+(childClass)
}

// 查询目标类的所有子类（直接和间接派生关系）
query predicate getChildClasses(Class parentClass, Class childClass) {
  isTargetClass(parentClass) and
  childClass = getADirectSubclass+(parentClass)
}

// 主查询：返回所有符合目标条件的类
from Class targetClass
where isTargetClass(targetClass)
select targetClass