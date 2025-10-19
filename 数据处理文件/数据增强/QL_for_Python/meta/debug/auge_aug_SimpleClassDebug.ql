/**
 * 分析目标类的继承层次结构
 * 包括父类链、子类链及目标类本身
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为目标类的谓词
predicate isTargetClass(Class candidateClass) {
  // 验证类名是否匹配目标名称
  candidateClass.getName() = "YourClassName"
  // 可选：验证类是否位于特定文件路径
  // and candidateClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的完整父类链（包括间接父类）
query predicate findSuperClasses(Class subClass, Class superClass) {
  isTargetClass(subClass) and
  superClass = getADirectSuperclass+(subClass)
}

// 查询目标类的完整子类链（包括间接子类）
query predicate findSubClasses(Class superClass, Class subClass) {
  isTargetClass(superClass) and
  subClass = getADirectSubclass+(superClass)
}

// 选择所有匹配的目标类
from Class candidateClass
where isTargetClass(candidateClass)
select candidateClass