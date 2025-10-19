/**
 * 检测特定类名及其继承层次结构
 * 该查询识别目标类及其所有父类（直接/间接）和子类（直接/间接）
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为目标类的谓词
predicate isTargetClass(Class targetCls) {
  // 检查类名是否匹配目标名称
  targetCls.getName() = "YourClassName"
  // 可选：检查类是否位于特定文件路径
  // and targetCls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的所有父类（包括间接继承）
query predicate findSuperClasses(Class childCls, Class parentCls) {
  isTargetClass(childCls) and
  parentCls = getADirectSuperclass+(childCls)
}

// 查询目标类的所有子类（包括间接继承）
query predicate findSubClasses(Class parentCls, Class childCls) {
  isTargetClass(parentCls) and
  childCls = getADirectSubclass+(parentCls)
}

// 选择所有目标类
from Class targetCls
where isTargetClass(targetCls)
select targetCls