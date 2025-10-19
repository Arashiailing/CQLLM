/**
 * 分析特定类名和文件路径的类继承层次
 * 本查询用于定位目标类，并展示其父类和子类的继承关系
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为目标类的谓词
predicate isTargetClass(Class targetClass) {
  // 检查类名是否匹配目标名称
  targetClass.getName() = "YourClassName"
  // 可选：检查类是否位于特定文件路径
  // and targetClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 获取目标类的所有父类（直接和间接）
predicate getSuperClasses(Class derivedClass, Class baseClass) {
  isTargetClass(derivedClass) and
  baseClass = getADirectSuperclass+(derivedClass)
}

// 获取目标类的所有子类（直接和间接）
predicate getSubClasses(Class baseClass, Class derivedClass) {
  isTargetClass(baseClass) and
  derivedClass = getADirectSubclass+(baseClass)
}

// 查询所有目标类
from Class targetClass
where isTargetClass(targetClass)
select targetClass