/**
 * @deprecated
 * @name 外部依赖关系分析
 * @description 统计Python源文件中引用的外部包依赖数量，帮助评估代码库的第三方包使用情况
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType externalDependency
 * @id py/external-dependencies
 */

import python
import semmle.python.dependencies.TechInventory

/*
 * 本查询用于分析Python代码库中的第三方包依赖关系，提供以下关键信息：
 *
 * 1. 源代码文件 - 包含外部依赖关系的Python源文件
 * 2. 外部包名称 - 指代从PyPI或其他外部仓库获取的包
 * 3. 版本规格 - 如果存在，包含包的版本约束信息
 * 4. 引用频率 - 表示源文件中对外部包的引用次数
 *
 * 查询结果虽然仅展示两列数据（包标识符和引用计数），但实际包含了上述四类信息。
 * 此设计是为了与当前仪表板数据库架构保持一致。
 * 任何列数变化都需要相应调整仪表板数据库和提取器。
 *
 * 注意：文件路径前添加了'/'前缀，以符合仪表板数据库中的相对路径格式。
 */

// 主查询：识别Python文件与外部包的依赖关系，并统计引用频率
from File sourceFile, int dependencyCount, string packageSignature, ExternalPackage externalPackage
where
  // 计算指定源文件中对外部包的引用次数
  dependencyCount =
    strictcount(AstNode astNode |
      // 验证AST节点是否依赖于指定的外部包
      dependency(astNode, externalPackage) and
      // 确保节点属于当前分析的源文件
      astNode.getLocation().getFile() = sourceFile
    ) and
  // 构建复合标识符，整合源文件和包信息
  packageSignature = munge(sourceFile, externalPackage)
// 返回结果：按引用频率降序排列的包标识符和计数
select packageSignature, dependencyCount order by dependencyCount desc