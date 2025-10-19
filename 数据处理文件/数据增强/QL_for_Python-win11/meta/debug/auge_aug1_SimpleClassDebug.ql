/**
 * 分析目标类及其继承层次结构
 * 通过类名精确匹配定位目标类，可选通过文件路径进一步过滤
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

// 查找目标类的所有祖先类（包括直接和间接父类）
query predicate findDirectSuperClass(Class cls, Class parent) {
  isTargetClass(cls) and
  parent = getADirectSuperclass+(cls)
}

// 查找目标类的所有后代类（包括直接和间接子类）
query predicate findDirectSubClass(Class cls, Class child) {
  isTargetClass(cls) and
  child = getADirectSubclass+(cls)
}

// 输出所有匹配的目标类
from Class cls
where isTargetClass(cls)
select cls