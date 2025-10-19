/**
 * @deprecated
 * @name 外部依赖关系
 * @description 计算一个Python源文件对外部包的依赖数量。
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType externalDependency
 * @id py/external-dependencies
 */

import python
import semmle.python.dependencies.TechInventory

/*
 * 分析Python源文件与外部包的依赖关系，量化每个文件对各个外部包的依赖程度。
 * 
 * 核心逻辑要素：
 * 1. 源代码文件路径（依赖主体）
 * 2. 外部包对象（PyPI等外部源提供的包）
 * 3. 包版本信息（可用时）
 * 4. 源文件对包的依赖计数
 * 
 * 输出格式说明：
 * - 第一列：依赖实体标识符（文件路径+包信息组合）
 * - 第二列：依赖计数（降序排列）
 * - 文件路径添加'/'前缀以匹配仪表板数据库格式
 */

// 定义查询变量：源文件、依赖计数、依赖实体、外部包
from File sourceFile, int depCount, string depEntity, ExternalPackage extPkg
where
  // 计算源文件对特定外部包的依赖数量
  depCount = strictcount(AstNode node |
    dependency(node, extPkg) and // 检查AST节点是否依赖指定外部包
    node.getLocation().getFile() = sourceFile // 确保节点位于目标源文件中
  ) and
  // 构建依赖实体标识符（合并文件路径和包信息）
  depEntity = munge(sourceFile, extPkg)
// 输出结果：依赖实体和依赖计数，按依赖数量降序排列
select depEntity, depCount order by depCount desc