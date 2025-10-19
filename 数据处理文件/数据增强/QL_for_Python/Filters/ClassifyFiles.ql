/**
 * @name Classify files
 * @description This query produces a list of all files in a snapshot
 *              that are classified as generated code or test code.
 * @kind file-classifier
 * @id py/file-classifier
 */

// 导入python模块，用于处理Python代码的查询
import python
// 导入GeneratedCode过滤器，用于识别生成的代码文件
import semmle.python.filters.GeneratedCode
// 导入Tests过滤器，用于识别测试代码文件
import semmle.python.filters.Tests

// 定义一个谓词函数classify，用于对文件进行分类
predicate classify(File f, string tag) {
  // 如果文件是生成的文件，则标记为"generated"
  f instanceof GeneratedFile and tag = "generated"
  // 或者如果文件属于某个测试范围，则标记为"test"
  or
  exists(TestScope t | t.getLocation().getFile() = f) and tag = "test"
}

// 从所有文件和标签中选择符合条件的文件和标签
from File f, string tag
where classify(f, tag)
select f, tag
