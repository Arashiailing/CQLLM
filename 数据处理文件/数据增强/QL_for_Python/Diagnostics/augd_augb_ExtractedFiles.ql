/**
 * @name 已提取的Python源文件
 * @description 此查询用于识别并展示源代码树中所有成功提取的Python源文件。
 *              通过检查文件是否存在有效的相对路径，可以确认该文件是否已正确提取。
 *              这对于验证代码库的完整性和确保所有Python模块都被正确处理非常重要。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

// 定义查询范围：所有Python文件
from File pyFile
where 
    // 筛选条件：文件必须具有有效的相对路径
    // 这表明文件已成功从源代码树中提取
    exists(pyFile.getRelativePath())
// 输出结果：文件对象和空字符串（保持格式一致性）
select pyFile, ""