/**
 * @deprecated
 * @name Keycloak CLI
 * @kind key-cli
 * @id py/keycloak_cli
 */

import python
import semmle.python.dataflow.new.DataFlow
import FluentApiSecurityQuery
import semmle.python.ApiGraphs

// 获取代表 Tar 文件提取操作的 API 节点
API::Node extract_operation(API::Node file_node, string method) {
  // 验证 file_node 是否为一个 tarfile 模块成员，如果是，则返回其 getmember 方法的结果
  file_node = API::moduleImport("tarfile").getMember("open").getReturn()
  // 确认提取方法（method）是有效的成员之一
  method in ["extract", "extractall"]
}

// 识别从任意来源（如用户输入）传递到 extract_operation 的数据流路径
from DataFlow::CallCfgNode target_call,
     DataFlow::Node tainted_input_source,
     API::Node file_argument,
     string extraction_method
where
  // 通过 API 查找符合 extract_operation 条件的目标调用
  target_call = extract_operation(file_argument, extraction_method).getMember(extraction_method)
     .getACall() and
  // 确保目标调用确实接收了一个参数
  target_call.getArg(0) = file_argument and
  // 验证传入的文件参数是否源自受污染的数据源
  tainted_input_source = file_argument.getAValueReachableFromSource() and
  // 增强过滤条件：排除实际存在的安全文件检查逻辑
  not exists(DataFlow::Node sanitizer |
    unsafe_extraction_protection(tainted_input_source, sanitizer)
  )
// 输出结果：调用节点、受污染源节点、错误消息及具体提取方法
select target_call.asExpr(), tainted_input_source, "The file name is controlled by a $@.", tainted_input_source,
  "potentially untrusted source", extraction_method