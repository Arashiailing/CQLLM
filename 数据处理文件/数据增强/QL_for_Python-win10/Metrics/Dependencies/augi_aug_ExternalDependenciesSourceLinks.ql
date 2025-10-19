/**
 * @deprecated
 * @name 外部依赖源链接
 * @kind source-link
 * @metricType externalDependency
 * @id py/dependency-source-links
 */

import python
import semmle.python.dependencies.TechInventory

/*
 * 本查询为ExternalDependencies.ql创建源链接。
 * 输出实体格式为'/file/path<|>dependency'，其中：
 * - /file/path是相对于源代码存档根目录的路径字符串，
 *   不与特定修订版绑定。
 * - 第二列的File实体用于在仪表板数据库中通过
 *   ExternalEntity.getASourceLink()方法恢复源链接信息。
 */

from File sourceFile, string depReference
where
  exists(PackageObject externalLib, AstNode codeNode |
    // 验证从代码节点到外部库的依赖关系存在
    dependency(codeNode, externalLib) and
    // 确保代码节点所属文件与源文件一致
    codeNode.getLocation().getFile() = sourceFile and
    // 通过munge函数组合源文件和外部库生成依赖引用
    depReference = munge(sourceFile, externalLib)
  )
select depReference, sourceFile