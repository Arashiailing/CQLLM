/**
 * 分析目标类的继承层次结构
 * 识别指定名称的类并追踪其完整的继承关系链
 * 包括所有直接/间接的父类和子类关系
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判定类是否为目标类的谓词
predicate isTargetClass(Class targetCls) {
  // 验证类名匹配预设目标名称
  targetCls.getName() = "YourClassName"
  // 可选：验证类路径匹配特定文件
  // and targetCls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 追溯目标类的完整父类链（包含间接继承）
query predicate traceSuperClasses(Class targetDerivedCls, Class baseCls) {
  isTargetClass(targetDerivedCls) and
  baseCls = getADirectSuperclass+(targetDerivedCls)
}

// 追溯目标类的完整子类链（包含间接继承）
query predicate traceSubClasses(Class targetBaseCls, Class derivedCls) {
  isTargetClass(targetBaseCls) and
  derivedCls = getADirectSubclass+(targetBaseCls)
}

// 选择所有匹配目标类定义的类
from Class targetCls
where isTargetClass(targetCls)
select targetCls