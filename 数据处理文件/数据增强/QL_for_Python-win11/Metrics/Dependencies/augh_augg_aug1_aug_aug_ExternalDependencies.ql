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
 * 本查询旨在分析Python代码库中外部包依赖的分布情况，提供以下关键信息：
 *
 * 分析维度：
 * 1. 源文件定位 - 识别包含外部依赖的Python源文件
 * 2. 包依赖检测 - 识别来自PyPI或其他外部仓库的包
 * 3. 版本约束获取 - 记录包的版本约束（如适用）
 * 4. 引用频率统计 - 计算源文件中对外部包的引用次数
 *
 * 实现细节：
 * - 查询输出采用两列格式，但包含上述四类信息
 * - 此设计确保与现有仪表板数据库架构的兼容性
 * - 输出列数变更需要同步更新仪表板数据库和提取器配置
 * - 文件路径添加前缀'/'以符合仪表板数据库的相对路径标准
 */

// 分析流程：建立源文件与外部包的关联，并量化依赖强度
from File pyFile, int depCount, string pkgIdentifier, ExternalPackage extPackage
where
  // 步骤1：计算源文件中引用特定外部包的次数
  depCount = 
    strictcount(AstNode node |
      // 确认AST节点引用了指定的外部包
      dependency(node, extPackage) and
      // 确保AST节点属于当前分析的源文件
      node.getLocation().getFile() = pyFile
    ) and
  // 步骤2：生成包含源文件和包信息的统一标识符
  pkgIdentifier = munge(pyFile, extPackage)
// 输出结果：按依赖引用频次降序排列的包标识符及其计数
select pkgIdentifier, depCount order by depCount desc