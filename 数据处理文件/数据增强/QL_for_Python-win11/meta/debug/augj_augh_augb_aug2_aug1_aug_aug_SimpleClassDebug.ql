/**
 * 类继承体系深度分析
 * 此查询用于识别指定分析类及其在继承链中的所有基类和派生类关系
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为待分析的目标类
predicate isAnalysisTarget(Class analysisClass) {
  // 检查类名与预设目标匹配
  analysisClass.getName() = "YourClassName"
  // 可选条件：验证类是否位于特定文件路径
  // and analysisClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的所有基类（包括直接和间接继承关系）
query predicate getBaseClasses(Class derivedClass, Class baseClass) {
  isAnalysisTarget(derivedClass) and
  baseClass = getADirectSuperclass+(derivedClass)
}

// 查询目标类的所有派生类（包括直接和间接派生关系）
query predicate getDerivedClasses(Class baseClass, Class derivedClass) {
  isAnalysisTarget(baseClass) and
  derivedClass = getADirectSubclass+(baseClass)
}

// 主查询：输出所有符合分析条件的类
from Class analysisClass
where isAnalysisTarget(analysisClass)
select analysisClass