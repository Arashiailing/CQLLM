/**
 * @name Python源文件提取状态检查
 * @description 检测并报告所有已成功提取的Python源代码文件。
 *              这些文件的特点是拥有有效的相对路径，表明它们已被正确解析。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

// 筛选条件：文件必须具有有效的相对路径
from File pythonSourceFile
where
  // 验证文件是否已成功提取（通过检查相对路径是否存在）
  pythonSourceFile.getRelativePath() instanceof string
// 输出结果：文件实例和诊断信息占位符
select pythonSourceFile, ""