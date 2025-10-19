/**
 * @name Cookie对象使用用户提供的数据构造
 * @description 通过用户输入直接构造Cookie对象可能引发Cookie投毒攻击，允许攻击者篡改或注入恶意Cookie值。
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

// 定义数据流路径查询，追踪从不可信输入到Cookie构造点的数据流
from 
  CookieInjectionFlow::PathNode untrustedInputSource,    // 表示未经验证的用户输入数据源
  CookieInjectionFlow::PathNode cookieConstructionPoint   // 表示Cookie对象的创建位置
where 
  // 确保存在从不可信输入到Cookie构造点的数据流路径
  CookieInjectionFlow::flowPath(untrustedInputSource, cookieConstructionPoint)
select 
  // 主要结果：Cookie构造位置
  cookieConstructionPoint.getNode(), 
  // 数据流起点：不可信输入源
  untrustedInputSource, 
  // 数据流终点：Cookie构造点
  cookieConstructionPoint, 
  // 警告消息模板
  "Cookie对象使用了来自$@的数据进行构造。", 
  // 消息中引用的数据源位置
  untrustedInputSource.getNode(),
  // 数据源描述文本
  "未经验证的用户输入"