/**
 * @name SQL query built from user-controlled sources
 * @description Constructing SQL queries using user-controlled input enables attackers
 *              to inject malicious SQL code, creating SQL injection vulnerabilities.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

// 导入Python代码解析与分析的核心库
import python

// 导入专门用于SQL注入数据流追踪的安全分析模块
import semmle.python.security.dataflow.SqlInjectionQuery

// 导入用于可视化数据流路径的图形化表示模块
import SqlInjectionFlow::PathGraph

// 定义数据流追踪：从用户输入源到SQL注入点的完整路径
from 
  SqlInjectionFlow::PathNode maliciousSource,  // 污染源节点（用户输入）
  SqlInjectionFlow::PathNode vulnerableSink     // 易受攻击的SQL注入点
where 
  SqlInjectionFlow::flowPath(maliciousSource, vulnerableSink)  // 验证数据流路径存在
select 
  vulnerableSink.getNode(),      // SQL注入漏洞的具体位置
  maliciousSource,              // 污染数据的源头节点
  vulnerableSink,               // 数据流终止点（漏洞点）
  "此SQL查询依赖于$@。",        // 漏洞描述模板
  maliciousSource.getNode(),    // 用于消息占位符的源节点
  "用户提供的值"                // 污染源的类型标签