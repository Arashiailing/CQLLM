/**
 * 类继承层次结构分析
 * 本查询用于识别目标类在继承体系中的所有直接和间接关联类
 * 包括父类（继承链）和子类（派生链）的完整层次结构
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为分析目标
predicate isTargetClass(Class clsOfInterest) {
  // 检查类名是否匹配预定义目标
  clsOfInterest.getName() = "YourClassName"
  // 可选条件：验证类是否位于特定文件路径
  // and clsOfInterest.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的所有上级类（包括直接和间接继承）
query predicate findSuperClasses(Class clsOfInterest, Class superCls) {
  isTargetClass(clsOfInterest) and
  superCls = getADirectSuperclass+(clsOfInterest)
}

// 查询目标类的所有下级类（包括直接和间接派生）
query predicate findSubClasses(Class clsOfInterest, Class subCls) {
  isTargetClass(clsOfInterest) and
  subCls = getADirectSubclass+(clsOfInterest)
}

// 选择所有符合目标条件的类
from Class clsOfInterest
where isTargetClass(clsOfInterest)
select clsOfInterest