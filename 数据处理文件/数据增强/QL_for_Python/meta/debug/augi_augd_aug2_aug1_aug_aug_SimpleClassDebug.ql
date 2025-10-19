/**
 * 类继承层次结构分析
 * 本查询识别指定类在继承体系中的所有直接和间接关联类
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为分析目标
predicate isAnalysisTarget(Class analysisTarget) {
  // 检查类名是否匹配预定义目标
  analysisTarget.getName() = "YourClassName"
  // 可选条件：验证类是否位于特定文件路径
  // and analysisTarget.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的所有上级类（包括直接和间接继承）
query predicate findAncestorClasses(Class analysisTarget, Class ancestorClass) {
  isAnalysisTarget(analysisTarget) and
  ancestorClass = getADirectSuperclass+(analysisTarget)
}

// 查询目标类的所有下级类（包括直接和间接派生）
query predicate findDescendantClasses(Class analysisTarget, Class descendantClass) {
  isAnalysisTarget(analysisTarget) and
  descendantClass = getADirectSubclass+(analysisTarget)
}

// 选择所有符合目标条件的类
from Class analysisTarget
where isAnalysisTarget(analysisTarget)
select analysisTarget