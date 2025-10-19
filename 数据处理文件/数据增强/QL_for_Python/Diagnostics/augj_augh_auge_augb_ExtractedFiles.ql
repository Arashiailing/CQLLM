/**
 * @name Python源文件提取验证
 * @description 识别代码库中已成功提取的Python源代码文件。
 *              通过验证文件是否包含有效的相对路径来确定提取状态。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

// 查询具有有效相对路径的Python源文件
// 这些文件表明已从源代码库中成功提取为Python模块
from File extractedPyFile
where exists(extractedPyFile.getRelativePath())
// 输出文件对象和空字符串（保持输出格式一致）
select extractedPyFile, ""