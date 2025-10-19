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
 * 此查询分析Python源文件与外部包之间的依赖关系，并计算每个源文件
 * 对每个外部包的依赖数量。结果以两列形式呈现：
 *
 * 1. dependencyEntity - 编码了源文件路径、外部包名称和版本信息的复合标识符
 * 2. dependencyCount - 源文件对外部包的依赖数量
 *
 * 源文件路径前添加了'/'前缀，以确保与仪表板数据库中使用的路径格式一致。
 * 这种格式是相对于源存档位置的隐式相对路径。
 */

// 从File类型的srcFile、int类型的dependencyCount、string类型的dependencyEntity和ExternalPackage类型的extPackage中选择数据
from File srcFile, int dependencyCount, string dependencyEntity, ExternalPackage extPackage
where
  // 计算特定源文件对特定外部包的依赖数量
  dependencyCount =
    strictcount(AstNode node |
      dependency(node, extPackage) and // 检查node节点是否依赖于指定的extPackage
      node.getLocation().getFile() = srcFile // 检查node节点所在的文件是否是指定的srcFile
    ) and
  // 将源文件和外部包信息合并为一个复合实体标识符
  dependencyEntity = munge(srcFile, extPackage)
// 选择dependencyEntity和dependencyCount列，并按dependencyCount降序排列结果
select dependencyEntity, dependencyCount order by dependencyCount desc