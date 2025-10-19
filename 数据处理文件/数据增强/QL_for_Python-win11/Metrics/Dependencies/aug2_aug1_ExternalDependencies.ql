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
 * 本查询分析Python源文件与外部包之间的依赖关系，并量化每个文件对各个外部包的依赖程度。
 * 
 * 查询逻辑包含以下核心要素：
 * 
 * 1. 源代码文件路径（作为依赖关系的主体）
 * 2. 外部包对象（通常指PyPI或类似外部源提供的包）
 * 3. 包的版本信息（如果可用）
 * 4. 源文件对该包的依赖数量统计
 * 
 * 当前实现返回两列数据：依赖实体标识符和依赖计数。
 * 文件路径前添加了'/'前缀，以与仪表板数据库中使用的相对文件路径格式保持一致。
 */

// 从Python源文件、外部包、依赖计数和依赖实体中选择数据
from File sourceCodeFile, int dependencyCount, string dependencyEntity, ExternalPackage externalPkg
where
  // 计算特定源文件对特定外部包的依赖数量
  dependencyCount =
    strictcount(AstNode codeNode |
      dependency(codeNode, externalPkg) and // 检查AST节点是否依赖于指定的外部包
      codeNode.getLocation().getFile() = sourceCodeFile // 确保AST节点位于指定的源文件中
    ) and
  // 将源文件和外部包信息合并为单个实体标识符
  dependencyEntity = munge(sourceCodeFile, externalPkg)
// 选择依赖实体和依赖计数，并按依赖数量降序排列
select dependencyEntity, dependencyCount order by dependencyCount desc