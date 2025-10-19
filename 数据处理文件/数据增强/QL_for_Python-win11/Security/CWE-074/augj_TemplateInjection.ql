/**
 * @name Server Side Template Injection
 * @description Detects when user-controlled input is used in template construction,
 *              potentially leading to remote code execution or cross-site scripting.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @security-severity 9.3
 * @id py/template-injection
 * @tags security
 *       external/cwe/cwe-074
 */

import python
import semmle.python.security.dataflow.TemplateInjectionQuery
import TemplateInjectionFlow::PathGraph

// 定义路径起点和终点节点
from TemplateInjectionFlow::PathNode entryPoint, TemplateInjectionFlow::PathNode targetPoint
// 验证存在从输入点到模板注入点的完整数据流路径
where TemplateInjectionFlow::flowPath(entryPoint, targetPoint)
// 输出结果：目标位置、输入源、路径及警告信息
select targetPoint.getNode(), 
       entryPoint, 
       targetPoint, 
       "This template construction depends on a $@.", 
       entryPoint.getNode(), 
       "user-provided value"