/**
 * 类继承关系深度分析工具
 * 
 * 核心功能：
 * - 精确定位目标类（通过类名匹配）
 * - 全量检索目标类的祖先类（直接/间接继承链）
 * - 全量检索目标类的后代类（直接/间接派生链）
 * 
 * 使用指南：
 * - 在 isTargetClass 谓词中配置目标类名
 * - 可选：通过文件路径条件缩小分析范围
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 目标类识别谓词
predicate isTargetClass(Class analysisTarget) {
  // 核心匹配条件：类名完全匹配
  analysisTarget.getName() = "YourClassName"
  // 可选扩展条件：限定文件路径
  // and analysisTarget.getLocation().getFile().getAbsolutePath().matches("%/specific/path.py")
}

// 祖先类检索：获取目标类的所有父类（含间接继承）
query predicate getAncestorClasses(Class descendant, Class ancestor) {
  isTargetClass(descendant) and
  ancestor = getADirectSuperclass+(descendant)
}

// 后代类检索：获取目标类的所有子类（含间接派生）
query predicate getDescendantClasses(Class base, Class derived) {
  isTargetClass(base) and
  derived = getADirectSubclass+(base)
}

// 主查询：输出所有匹配的目标类
from Class targetClass
where isTargetClass(targetClass)
select targetClass