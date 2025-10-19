/**
 * @name 计算用户编写的Python代码总行数
 * @description 本查询用于统计源代码仓库中用户编写的Python代码总行数，自动生成的文件将被排除。
 *   统计仅包含实际代码行，空白行和注释不计入。请注意，当前实现会将代码库中的外部依赖
 *   （如签入的虚拟环境或第三方库）视为用户代码进行统计。
 * @kind metric
 * @tags summary
 *       代码行数
 *       调试
 * @id py/summary/lines-of-user-code
 */

import python // 导入Python分析支持模块
import semmle.python.filters.GeneratedCode // 导入生成代码识别过滤器

from Module sourceModule
// 筛选条件：模块位于源代码目录且非自动生成
where exists(sourceModule.getFile().getRelativePath()) and
      not sourceModule.getFile() instanceof GeneratedFile
// 计算所有符合条件的源代码模块的代码行数总和
select sum(sourceModule.getMetrics().getNumberOfLinesOfCode())