/**
 * 检查指定类名和文件路径的类层次结构
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为目标类的谓词
predicate isTargetClass(Class cls) {
  // 验证类名匹配目标名称
  cls.getName() = "YourClassName"
  // 可选：验证类是否位于特定文件路径
  // and cls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的直接父类
query predicate findSuperClasses(Class childCls, Class parentCls) {
  isTargetClass(childCls) and
  parentCls = getADirectSuperclass+(childCls)
}

// 查询目标类的直接子类
query predicate findSubClasses(Class parentCls, Class childCls) {
  isTargetClass(parentCls) and
  childCls = getADirectSubclass+(parentCls)
}

// 选择所有目标类
from Class clsOfInterest
where isTargetClass(clsOfInterest)
select clsOfInterest