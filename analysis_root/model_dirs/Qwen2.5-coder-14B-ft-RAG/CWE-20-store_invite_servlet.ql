/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind path-problem
 * @id py/store_invite_servlet
 * @problem.severity error
 * @security-severity 7.8
 * @precision high
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

import python
import semmle.python.Concepts

from HttpServer::Request request, HttpServer::Response response
where
  // 查找响应对象的start_response方法调用
  exists(HttpServer::StartResponse sr |
    sr = response.getStartResponse() and
    // 确保请求和响应之间的关联性
    request.getResponse() = response and
    // 验证请求参数是否被直接传递给start_response方法
    request.getAnInboundFlowNode().getNode().getAFlowNode*() = sr.getParameter(0)
  )
select response,
  "Part of the $@ header is copied to the response without validation.",
  request, "request"