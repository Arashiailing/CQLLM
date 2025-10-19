/**
 * @name 已成功提取的Python文件清单
 * @description 此查询用于识别并列出项目中所有已成功提取的Python源文件。
 *              成功提取的文件是指那些在数据库中具有有效相对路径的文件。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

// 选择所有具有有效相对路径的Python文件
from File pythonFile
where exists(pythonFile.getRelativePath())
// 输出文件对象和空字符串（用于格式化输出）
select pythonFile, ""