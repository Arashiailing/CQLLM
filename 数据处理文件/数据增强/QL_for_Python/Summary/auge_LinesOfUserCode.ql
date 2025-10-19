/**
 * @name 用户编写的Python代码总行数统计
 * @description 统计源代码目录中用户编写的Python代码总行数，不包含自动生成的文件。
 *   此查询计算非空白行和非注释行的代码行数。注意：当前实现中，外部库（包括签入的虚拟环境
 *   或供应商代码）会被统计为用户编写的代码。
 * @kind metric
 * @tags summary
 *       代码行数
 *       调试
 * @id py/summary/lines-of-user-code
 */

import python // 导入Python分析模块
import semmle.python.filters.GeneratedCode // 导入自动生成代码过滤器模块

// 定义符合条件的Python模块：有相对路径且非自动生成
bindingset[pyModule]
predicate isValidUserModule(Module pyModule) {
  exists(pyModule.getFile().getRelativePath()) and
  not pyModule.getFile() instanceof GeneratedFile
}

// 计算所有有效用户模块的代码行数总和
select sum(Module pyModule |
    isValidUserModule(pyModule)
  |
    // 获取该模块的代码行数指标
    pyModule.getMetrics().getNumberOfLinesOfCode()
  )