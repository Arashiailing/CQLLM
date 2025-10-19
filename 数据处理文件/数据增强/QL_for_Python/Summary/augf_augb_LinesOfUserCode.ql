/**
 * @name 用户Python代码行数统计
 * @description 计算项目中用户编写的Python代码的实际行数总和，自动生成的文件不计入统计。
 *   此查询专注于统计有效代码行，忽略空白行和注释。请注意，当前实现会将项目中的外部库
 *   （如签入的虚拟环境或第三方供应商代码）视为用户编写的代码一并统计。
 * @kind metric
 * @tags summary
 *       代码行数
 *       调试
 * @id py/summary/lines-of-user-code
 */

import python // 导入Python分析模块
import semmle.python.filters.GeneratedCode // 导入自动生成代码过滤器模块

// 计算所有符合条件的源代码模块的代码行数总和
select sum(Module sourceModule |
    // 确保模块位于源代码目录中
    exists(sourceModule.getFile().getRelativePath()) and
    // 排除自动生成的文件
    not sourceModule.getFile() instanceof GeneratedFile
  |
    // 计算模块的有效代码行数
    sourceModule.getMetrics().getNumberOfLinesOfCode()
  )