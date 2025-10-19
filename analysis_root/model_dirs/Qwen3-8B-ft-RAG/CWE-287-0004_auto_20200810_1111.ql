import python
import semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs
import semmle.python.filters.Tests

/**
 * @name Improper LDAP Authentication
 * @description A user-controlled query carries no authentication
 * @kind path-problem
 * @problem.severity warning
 * @id py/improper-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-287
 */

// 定义查询谓词，用于判断是否存在不当的LDAP认证
predicate authenticatesImproperly(LdapBind ldapBind) {
  // 如果存在从任意None值到ldapBind密码的局部数据流，或者ldapBind没有设置密码，则返回true
  (
    exists(DataFlow::LocalSource source | 
      DataFlow::flowPath(source.asCfgNode(), ldapBind.getPassword()) and 
      not exists(source.asExpr()) // 检查源节点是否不是常量
    )
    or
    not exists(ldapBind.getPassword())
  )
  and
  not exists(Http::Server::Request r | r.writeTo(Http::Server::Response::new(ldapBind)) ) // 检查是否存在从HTTP服务器请求到响应的流
  and
  not ldapBind.getEncrypted() // 检查ldapBind是否未加密
  and
  not testScope(ldapBind) // 检查ldapBind是否不在测试范围内
}

// 定义变量和查询谓词
from DataFlow::Node source, LdapBind ldapBind
where
  authenticatesImproperly(ldapBind) and // 条件：ldapBind使用了不安全的认证方式
  ldapBind.performAuth() and // 条件：ldapBind执行了认证操作
  source = ldapBind.getADomain() and // 条件：source是ldapBind的域
  not testScope(source) // 条件：source不在测试范围内
select ldapBind, "This LDAP bind uses $@.", source, source.toString() // 选择ldapBind并生成警告信息