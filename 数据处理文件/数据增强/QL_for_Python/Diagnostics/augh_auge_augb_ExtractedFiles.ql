/**
 * @name Python源文件提取验证
 * @description 检测代码库中所有正确提取的Python源代码文件。
 *              通过检查文件是否拥有可用的相对路径来判断文件提取状态。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

// 筛选出所有具有有效相对路径的Python源文件
// 这类文件表明已从源代码库中成功提取为Python模块
from File pythonFile
where exists(pythonFile.getRelativePath())
// 返回文件对象和空字符串（维持输出格式一致）
select pythonFile, ""