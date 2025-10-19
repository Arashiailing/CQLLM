/**
 * 定位指定类并分析其继承层次结构
 * 通过类名匹配目标类，支持可选的文件路径过滤
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为目标类的谓词
predicate isDesiredClass(Class cls) {
  // 精确匹配类名
  cls.getName() = "YourClassName"
  // 可选：通过文件路径进一步限定
  // and cls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查找目标类的直接父类
query predicate findImmediateSuperClass(Class cls, Class parent) {
  isDesiredClass(cls) and
  parent = getADirectSuperclass+(cls)
}

// 查找目标类的直接子类
query predicate findImmediateSubClass(Class cls, Class child) {
  isDesiredClass(cls) and
  child = getADirectSubclass+(cls)
}

// 输出所有匹配的目标类
query predicate findTargetClasses(Class cls) {
  isDesiredClass(cls)
}