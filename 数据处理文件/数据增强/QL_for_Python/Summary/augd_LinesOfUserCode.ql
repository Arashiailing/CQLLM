/**
 * @name 数据库中用户编写的Python代码总行数
 * @description 计算源代码目录中Python代码的总行数，自动生成的文件不计入统计。
 *   该统计不包括空白行或注释行。请注意，如果代码库中包含外部库（无论是签入的虚拟环境
 *   还是供应商代码），目前都会被计为用户编写的代码。
 * @kind metric
 * @tags summary
 *       代码行数
 *       调试
 * @id py/summary/lines-of-user-code
 */

import python // 导入python分析模块
import semmle.python.filters.GeneratedCode // 导入自动生成代码过滤器模块

// 计算所有符合条件的Python模块的代码行数总和
select sum(Module pyModule |
    // 筛选条件：模块文件必须具有相对路径且非自动生成
    exists(pyModule.getFile().getRelativePath()) and
    not pyModule.getFile() instanceof GeneratedFile
  |
    // 获取每个模块的代码行数指标
    pyModule.getMetrics().getNumberOfLinesOfCode()
  )