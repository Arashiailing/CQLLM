/**
 * 检测目标类及其继承关系
 * 通过类名精确匹配目标类，可选通过文件路径进一步限定范围
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为目标类的谓词
predicate isTargetClass(Class targetCls) {
  // 精确匹配目标类名
  targetCls.getName() = "YourClassName"
  // 可选：通过文件路径进一步限定范围
  // and targetCls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查找目标类的直接或间接父类
query predicate findSuperClass(Class targetCls, Class superClass) {
  isTargetClass(targetCls) and
  superClass = getADirectSuperclass+(targetCls)
}

// 查找目标类的直接或间接子类
query predicate findSubClass(Class targetCls, Class subClass) {
  isTargetClass(targetCls) and
  subClass = getADirectSubclass+(targetCls)
}

// 输出所有匹配的目标类
from Class targetCls
where isTargetClass(targetCls)
select targetCls