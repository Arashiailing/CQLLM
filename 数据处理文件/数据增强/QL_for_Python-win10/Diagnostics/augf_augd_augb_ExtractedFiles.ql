/**
 * @name 已提取的Python源文件
 * @description 本查询用于检测并展示代码库中所有成功提取的Python源文件。
 *              通过验证文件是否具备有效的相对路径，可以确认该文件是否已从源代码树中正确提取。
 *              这对于确保代码库的完整性以及验证所有Python模块是否被正确处理至关重要。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

// 定义查询范围：遍历所有Python源文件
from File extractedPyFile
where 
    // 筛选条件：文件必须拥有有效的相对路径
    // 有效相对路径的存在表明文件已成功从源代码树中提取
    exists(extractedPyFile.getRelativePath())
// 输出结果：文件对象和空字符串（维持格式一致性）
select extractedPyFile, ""