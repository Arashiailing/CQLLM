/**
 * 检测特定类名和文件路径的类继承关系
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为目标类的谓词
predicate isTargetClass(Class targetCls) {
  // 验证类名是否匹配目标名称
  targetCls.getName() = "YourClassName"
  // 可选：验证类是否位于特定文件路径
  // and targetCls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的直接父类
query predicate findSuperClasses(Class subCls, Class superCls) {
  isTargetClass(subCls) and
  superCls = getADirectSuperclass+(subCls)
}

// 查询目标类的直接子类
query predicate findSubClasses(Class superCls, Class subCls) {
  isTargetClass(superCls) and
  subCls = getADirectSubclass+(superCls)
}

// 选择所有目标类
from Class targetCls
where isTargetClass(targetCls)
select targetCls