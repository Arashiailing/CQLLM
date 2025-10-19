/**
 * @name Overly permissive file permissions
 * @description Allowing files to be readable or writable by users other than the owner may allow sensitive information to be accessed.
 * @kind problem
 * @id py/overly-permissive-file
 * @problem.severity warning
 * @security-severity 7.8
 * @sub-severity high
 * @precision medium
 * @tags external/cwe/cwe-732
 *       security
 */

import python
import semmle.python.ApiGraphs

// 定义一个绑定集，用于计算文件权限中的“world”部分。
bindingset[p]
int world_permission(int p) { result = p % 8 }

// 定义一个绑定集，用于计算文件权限中的“group”部分。
bindingset[p]
int group_permission(int p) { result = (p / 8) % 8 }

// 定义一个绑定集，用于将权限数值转换为可读的字符串表示形式。
bindingset[p]
string access(int p) {
  p % 4 >= 2 and result = "writable" // 如果权限数值的最后两位大于等于2，则表示可写。
  or
  p % 4 < 2 and p != 0 and result = "readable" // 如果权限数值的最后两位小于2且不为0，则表示可读。
}

// 定义一个绑定集，用于判断权限是否过于宽松，并返回相应的描述。
bindingset[p]
string permissive_permission(int p) {
  result = "world " + access(world_permission(p)) // 如果world权限不为0，则返回world权限的描述。
  or
  world_permission(p) = 0 and result = "group " + access(group_permission(p)) // 如果world权限为0，则返回group权限的描述。
}

// 定义一个谓词，用于匹配调用os.chmod函数的API调用节点。
predicate chmod_call(API::CallNode call, string name, int mode) {
  call = API::moduleImport("os").getMember("chmod").getACall() and // 匹配os.chmod函数调用。
  mode = call.getParameter(1, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and // 获取mode参数的值。
  name = "chmod" // 设置name为"chmod"。
}

// 定义一个谓词，用于匹配调用os.open函数的API调用节点。
predicate open_call(API::CallNode call, string name, int mode) {
  call = API::moduleImport("os").getMember("open").getACall() and // 匹配os.open函数调用。
  mode = call.getParameter(2, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and // 获取mode参数的值。
  name = "open" // 设置name为"open"。
}

// 查询语句：查找所有调用os.chmod或os.open函数时设置了过于宽松的文件权限的情况。
from API::CallNode call, string name, int mode, string permission
where
  (chmod_call(call, name, mode) or open_call(call, name, mode)) and // 匹配调用os.chmod或os.open函数的API调用节点。
  permission = permissive_permission(mode) // 检查权限是否过于宽松。
select call, "Overly permissive mask in " + name + " sets file to " + permission + "." // 选择并报告这些调用节点及其对应的权限描述。
