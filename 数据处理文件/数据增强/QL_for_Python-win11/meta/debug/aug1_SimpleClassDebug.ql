/**
 * 检查指定类及其层次结构关系
 * 通过类名和文件路径定位目标类
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为目标类的谓词
predicate isTargetClass(Class targetClass) {
  // 匹配指定类名
  targetClass.getName() = "YourClassName"
  // 可选：通过文件路径进一步限定
  // and targetClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查找目标类的直接父类
query predicate findDirectSuperClass(Class targetClass, Class superClass) {
  isTargetClass(targetClass) and
  superClass = getADirectSuperclass+(targetClass)
}

// 查找目标类的直接子类
query predicate findDirectSubClass(Class targetClass, Class subClass) {
  isTargetClass(targetClass) and
  subClass = getADirectSubclass+(targetClass)
}

// 输出所有匹配的目标类
from Class targetClass
where isTargetClass(targetClass)
select targetClass