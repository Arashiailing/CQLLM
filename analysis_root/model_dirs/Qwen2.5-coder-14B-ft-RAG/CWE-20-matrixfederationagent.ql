/**
* @name CWE-20: Improper Input Validation
* @description The product receives input or data, but it does
*              not validate or incorrectly validates that the input has the
*              properties that are required to process the data safely and
*              correctly.
* @kind problem
* @problem.severity error
* @security-severity 7.8
* @precision high
* @id py/matrixfederationagent
* @tags correctness
*       security
*       external/cwe/cwe-20
*/

import python
import semmle.python.filters.Tests
import MatrixFederationAgentSemgrepQuery::MatrixFederationAgentSemgrepQuery

from Semmle_python::Global g, MatrixFederationAgentSemgrepQuery::Result r, string name
where
  // 验证项目是否符合联邦代理规则
  matrix_federation_agent_rule(g, r, name)
  // 确保项目不是测试代码
  and not Tests::testFile(r.getFile())
select r.getStartLine(), r.getMessage(), name