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
 * 本查询提供Python项目外部依赖关系的量化分析，输出包含以下关键信息：
 *
 * 目的：
 *   - 识别并统计Python源文件中的外部依赖关系
 *   - 量化每个源文件对各外部包的引用频率
 *
 * 输出维度：
 *   1. 源文件路径 - 作为依赖分析的主体文件
 *   2. 外部包对象 - 表示从PyPI或其他外部源引入的依赖包
 *   3. 版本信息 - 当可获取时包含的包版本详情
 *   4. 依赖计数 - 源文件中引用特定外部包的次数
 *
 * 技术说明：
 *   - 当前实现输出两列数据（依赖实体和计数），实际涵盖四个信息维度
 *   - 文件路径添加'/'前缀，以保持与仪表板数据库中使用的相对路径格式一致
 *   - 结果按依赖频率降序排列，便于识别高频依赖项
 */

// 定义查询变量，使用更具描述性的名称
from File pythonSourceFile, ExternalPackage externalDependency, int dependencyFrequency, string dependencyIdentifier
where
  // 计算特定源文件对外部包的依赖频率
  dependencyFrequency =
    strictcount(AstNode astNode |
      // 检查AST节点是否依赖于指定的外部包
      dependency(astNode, externalDependency) and
      // 确保AST节点位于当前分析的源文件中
      astNode.getLocation().getFile() = pythonSourceFile
    ) and
  // 构建统一的依赖标识符，包含源文件和外部包信息
  dependencyIdentifier = munge(pythonSourceFile, externalDependency)
// 输出依赖标识符及其频率，按依赖频率降序排列
select dependencyIdentifier, dependencyFrequency order by dependencyFrequency desc