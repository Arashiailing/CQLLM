/**
 * 查询特定类及其继承关系
 * 通过类名和可选文件路径精确定位目标类
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为特定目标类的谓词
predicate isDesiredClass(Class targetCls) {
  // 匹配指定的类名
  targetCls.getName() = "YourClassName"
  // 可选：通过文件路径进一步限定
  // and targetCls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查找目标类的所有父类（包括直接和间接父类）
query predicate findAncestorClasses(Class targetCls, Class ancestorCls) {
  isDesiredClass(targetCls) and
  ancestorCls = getADirectSuperclass+(targetCls)
}

// 查找目标类的所有子类（包括直接和间接子类）
query predicate findDescendantClasses(Class targetCls, Class descendantCls) {
  isDesiredClass(targetCls) and
  descendantCls = getADirectSubclass+(targetCls)
}

// 输出所有匹配的目标类
from Class targetCls
where isDesiredClass(targetCls)
select targetCls