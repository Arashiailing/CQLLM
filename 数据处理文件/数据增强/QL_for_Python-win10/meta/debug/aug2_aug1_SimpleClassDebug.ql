/**
 * 检查指定类及其继承层次结构
 * 通过类名匹配目标类，可选通过文件路径进一步限定范围
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为目标类的谓词
predicate isDesiredClass(Class cls) {
  // 匹配指定类名
  cls.getName() = "YourClassName"
  // 可选：通过文件路径进一步限定
  // and cls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查找目标类的直接父类
query predicate findParentClass(Class desiredClass, Class parentClass) {
  isDesiredClass(desiredClass) and
  parentClass = getADirectSuperclass+(desiredClass)
}

// 查找目标类的直接子类
query predicate findChildClass(Class desiredClass, Class childClass) {
  isDesiredClass(desiredClass) and
  childClass = getADirectSubclass+(desiredClass)
}

// 输出所有匹配的目标类
from Class desiredClass
where isDesiredClass(desiredClass)
select desiredClass