/**
 * @deprecated
 * @name 外部依赖关系
 * @description 统计Python源文件中引用的外部包依赖数量
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType externalDependency
 * @id py/external-dependencies
 */

import python
import semmle.python.dependencies.TechInventory

/*
 * 本查询用于分析Python代码库中的外部包依赖分布，提供以下关键分析维度：
 *
 * 核心分析维度：
 * 1. 源文件定位 - 精确识别包含外部依赖的Python源文件
 * 2. 包依赖识别 - 准确定位来自PyPI或其他外部仓库的具体包
 * 3. 版本信息捕获 - 记录并追踪包的版本约束信息（当可用时）
 * 4. 引用频率量化 - 统计源文件中对外部包的引用次数
 *
 * 技术实现说明：
 * - 查询输出为两列格式，但实际包含上述四类分析信息
 * - 此架构设计确保与现有仪表板数据库架构的兼容性
 * - 修改输出列数需要同步更新仪表板数据库和提取器配置
 * - 文件路径添加前缀'/'以符合仪表板数据库的相对路径标准
 */

// 分析流程：首先识别源文件与外部包的关联关系，然后量化依赖强度
from File pySourceFile, int extDepCount, string pkgIdentifier, ExternalPackage extPkg
where
  // 构造统一的包标识符，整合源文件和包信息
  pkgIdentifier = munge(pySourceFile, extPkg) and
  // 计算特定源文件中引用外部包的频次
  extDepCount =
    strictcount(AstNode codeNode |
      // 确保AST节点隶属于当前分析的源文件
      codeNode.getLocation().getFile() = pySourceFile and
      // 验证AST节点是否引用了指定的外部包
      dependency(codeNode, extPkg)
    )
// 结果输出：按依赖频次降序排列的包标识符及其计数
select pkgIdentifier, extDepCount order by extDepCount desc