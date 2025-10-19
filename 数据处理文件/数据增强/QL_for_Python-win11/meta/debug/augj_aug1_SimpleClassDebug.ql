/**
 * 检测指定类及其继承关系
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

// 查找目标类的直接父类（递归包含所有祖先类）
query predicate findDirectSuperClass(Class cls, Class parentCls) {
  isTargetClass(cls) and
  parentCls = getADirectSuperclass+(cls)
}

// 查找目标类的直接子类（递归包含所有后代类）
query predicate findDirectSubClass(Class cls, Class childCls) {
  isTargetClass(cls) and
  childCls = getADirectSubclass+(cls)
}

// 输出所有匹配的目标类
from Class cls
where isTargetClass(cls)
select cls