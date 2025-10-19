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
 * 此查询用于识别并统计Python源文件中的外部依赖关系。
 * 
 * 查询核心功能包括：
 * 
 * - 确定每个Python源文件（作为依赖主体）
 * - 识别所有相关的外部包（来自PyPI或其他外部源）
 * - 收集包的版本信息（当可用时）
 * - 计算每个文件对各外部包的依赖数量
 * 
 * 输出结果包含两列：合并的依赖标识符和依赖计数。
 * 文件路径添加了'/'前缀，确保与仪表板数据库中使用的相对路径格式一致。
 */

// 定义查询所需的数据来源：Python源文件、依赖计数、依赖实体和外部包
from File pySourceFile, int depCount, string depEntity, ExternalPackage extPackage
where
  // 计算指定Python源文件对特定外部包的依赖总数
  depCount =
    strictcount(AstNode astNode |
      dependency(astNode, extPackage) and // 验证AST节点是否依赖于目标外部包
      astNode.getLocation().getFile() = pySourceFile // 确保AST节点属于当前源文件
    ) and
  // 构建统一的依赖实体标识符，合并源文件和外部包信息
  depEntity = munge(pySourceFile, extPackage)
// 输出依赖实体及其计数，并按依赖数量从高到低排序
select depEntity, depCount order by depCount desc