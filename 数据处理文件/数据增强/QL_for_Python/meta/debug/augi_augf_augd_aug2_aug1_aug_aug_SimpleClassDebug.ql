/**
 * 类继承层次结构深度分析
 * 本查询旨在识别目标类在继承体系中的所有直接和间接关联类
 * 包括父类（继承链）和子类（派生链）的完整层次结构映射
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为指定的分析目标
predicate isTargetClass(Class targetCls) {
  // 检查类名是否匹配预定义目标
  targetCls.getName() = "YourClassName"
  // 可选条件：验证类是否位于特定文件路径
  // and targetCls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的所有祖先类（包括直接和间接继承）
query predicate findSuperClasses(Class targetCls, Class ancestorClass) {
  isTargetClass(targetCls) and
  ancestorClass = getADirectSuperclass+(targetCls)
}

// 查询目标类的所有后代类（包括直接和间接派生）
query predicate findSubClasses(Class targetCls, Class descendantClass) {
  isTargetClass(targetCls) and
  descendantClass = getADirectSubclass+(targetCls)
}

// 选择所有符合目标条件的类
from Class targetCls
where isTargetClass(targetCls)
select targetCls