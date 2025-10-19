/**
 * @deprecated
 * @name 外部依赖关系统计
 * @description 分析并量化Python源文件所依赖的外部包的数量分布情况。
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType externalDependency
 * @id py/external-dependencies
 */

import python
import semmle.python.dependencies.TechInventory

/*
 * Python项目外部依赖关系量化分析
 * 
 * 功能概述：
 *   - 识别Python源文件中的外部依赖包
 *   - 统计每个源文件对各外部包的引用频率
 * 
 * 输出信息维度：
 *   1. 源文件路径 - 作为分析主体的Python文件
 *   2. 外部包对象 - 从PyPI等外部源引入的依赖包
 *   3. 版本信息 - 可获取时的包版本详情
 *   4. 引用计数 - 源文件中引用特定外部包的次数
 * 
 * 实现细节：
 *   - 输出两列数据，实际涵盖四个信息维度
 *   - 文件路径添加'/'前缀，保持与仪表板数据库格式一致
 *   - 结果按引用频率降序排列，便于识别高频依赖项
 */

// 定义查询变量，使用更简洁的命名
from File srcFile, ExternalPackage extPkg, int refCount, string depId
where
  // 统计源文件中对外部包的引用次数
  refCount = strictcount(AstNode node |
    // 确保AST节点依赖于指定外部包且位于当前源文件中
    dependency(node, extPkg) and
    node.getLocation().getFile() = srcFile
  ) and
  // 构建包含源文件和外部包信息的依赖标识符
  depId = munge(srcFile, extPkg)
// 输出依赖标识符及其引用次数，按引用频率降序排列
select depId, refCount order by refCount desc