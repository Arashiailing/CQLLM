/**
 * @name CWE-287: Improper Authentication
 * @description When an actor claims to have a given identity, the product does not prove or insufficiently proves that the claim is correct.
 * @kind problem
 * @problem.severity error
 * @security-severity 8.1
 * @precision medium
 * @id py/0004_auto_20200810_1111
 * @tags correctness
 *       security
 */

import python
import semmle.python.dataflow.new.DataFlow
import FluentApiModel

// 从FluentApiModel模块中导入所需的谓词
from Http::Server::HttpHeader header, string headerName
where
  // 获取HTTP头的名称，并将其转换为小写
  headerName = header.getName().toLowerCase() and
  // 验证是否为基本身份验证头
  headerName in ["authorization", "proxy-authorization"] and
  // 检查是否存在Basic认证但缺少凭据验证的情况
  header.hasTaintedValueWithPrefix("basic") and
  not header.hasValueSuffix(": ")
select header,
  "Authorization header uses Basic authentication without verifying the provided credentials."