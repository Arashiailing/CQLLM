/**
 * @name Python用户代码行数统计
 * @description 此查询计算代码库中由用户编写的Python代码总行数，排除自动生成的文件。
 *   仅统计实际代码行，不包括空白行和注释。注意：当前实现会将代码库中的外部依赖
 *   （如签入的虚拟环境或第三方库）视为用户代码进行统计。
 * @kind metric
 * @tags summary
 *       代码行数
 *       调试
 * @id py/summary/lines-of-user-code
 */

import python // 导入Python分析支持模块
import semmle.python.filters.GeneratedCode // 导入生成代码识别过滤器

from Module nonGeneratedModule
// 筛选条件：模块位于源代码目录且非自动生成
where 
  exists(nonGeneratedModule.getFile().getRelativePath()) and
  not nonGeneratedModule.getFile() instanceof GeneratedFile
// 计算所有符合条件的源代码模块的代码行数总和
select sum(nonGeneratedModule.getMetrics().getNumberOfLinesOfCode())