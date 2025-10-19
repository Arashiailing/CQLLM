/**
 * 定位特定类及其继承关系
 * 通过类名和可选文件路径精确定位目标类
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为目标类的谓词
predicate isTargetClass(Class cls) {
  // 匹配指定类名
  cls.getName() = "YourClassName"
  // 可选：通过文件路径进一步限定
  // and cls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查找目标类的所有父类（直接和间接）
query predicate findSuperClasses(Class cls, Class parentClass) {
  isTargetClass(cls) and
  parentClass = getADirectSuperclass+(cls)
}

// 查找目标类的所有子类（直接和间接）
query predicate findSubClasses(Class cls, Class childClass) {
  isTargetClass(cls) and
  childClass = getADirectSubclass+(cls)
}

// 输出所有匹配的目标类
from Class cls
where isTargetClass(cls)
select cls