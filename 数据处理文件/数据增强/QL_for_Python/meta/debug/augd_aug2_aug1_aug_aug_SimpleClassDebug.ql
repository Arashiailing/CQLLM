/**
 * 分析类继承层次结构
 * 本查询用于识别指定类在继承体系中的所有直接和间接关联类
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为分析目标
predicate isTargetClass(Class targetCls) {
  // 检查类名是否匹配预定义目标
  targetCls.getName() = "YourClassName"
  // 可选条件：验证类是否位于特定文件路径
  // and targetCls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的所有上级类（包括直接和间接继承）
query predicate findSuperClasses(Class targetCls, Class ancestorCls) {
  isTargetClass(targetCls) and
  ancestorCls = getADirectSuperclass+(targetCls)
}

// 查询目标类的所有下级类（包括直接和间接派生）
query predicate findSubClasses(Class targetCls, Class descendantCls) {
  isTargetClass(targetCls) and
  descendantCls = getADirectSubclass+(targetCls)
}

// 选择所有符合目标条件的类
from Class targetCls
where isTargetClass(targetCls)
select targetCls