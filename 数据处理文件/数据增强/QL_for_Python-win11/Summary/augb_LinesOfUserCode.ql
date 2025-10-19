/**
 * @name 计算用户编写的Python代码总行数
 * @description 统计源代码目录中用户编写的Python代码总行数，排除自动生成的文件。
 *   该查询仅计算实际代码行数，不包括空白行和注释。需要注意的是，如果代码库中包含外部库
 *   （无论是作为签入的虚拟环境还是供应商代码），目前都会被视为用户编写的代码进行统计。
 * @kind metric
 * @tags summary
 *       代码行数
 *       调试
 * @id py/summary/lines-of-user-code
 */

import python // 导入Python分析模块
import semmle.python.filters.GeneratedCode // 导入自动生成代码过滤器模块

// 计算所有符合条件的用户模块的代码行数总和
select sum(Module userModule |
    // 检查模块文件是否具有相对路径（表示它位于源代码目录中）
    exists(userModule.getFile().getRelativePath()) and
    // 确保模块不是自动生成的文件
    not userModule.getFile() instanceof GeneratedFile
  |
    // 获取用户模块的代码行数指标
    userModule.getMetrics().getNumberOfLinesOfCode()
  )