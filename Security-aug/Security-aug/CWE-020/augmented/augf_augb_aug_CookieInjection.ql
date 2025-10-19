/**
 * @name Cookie对象使用用户提供的数据构造
 * @description 使用用户输入构造Cookie可能导致Cookie投毒攻击，攻击者可以修改或注入恶意Cookie值。
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// 导入Python代码分析基础库
import python

// 导入Cookie注入安全分析模块
import semmle.python.security.dataflow.CookieInjectionQuery

// 导入数据流路径图表示模块
import CookieInjectionFlow::PathGraph

// 查找所有从不可信数据源到Cookie构造点的数据流路径
from 
  CookieInjectionFlow::PathNode untrustedDataSource,  // 未经验证的用户输入数据源
  CookieInjectionFlow::PathNode cookieCreationPoint   // Cookie对象创建位置
where 
  // 验证数据流路径存在性
  CookieInjectionFlow::flowPath(untrustedDataSource, cookieCreationPoint)
select 
  // 输出Cookie构造位置
  cookieCreationPoint.getNode(), 
  // 输出数据源节点
  untrustedDataSource, 
  // 输出路径终点
  cookieCreationPoint, 
  // 输出问题描述
  "Cookie对象使用了来自$@的数据进行构造。", 
  // 输出数据源位置
  untrustedDataSource.getNode(),
  // 输出数据源描述
  "未经验证的用户输入"