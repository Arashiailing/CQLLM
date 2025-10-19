/**
 * @name SSL/TLS默认版本可能不安全
 * @description 未指定SSL/TLS版本可能导致使用不安全的默认协议。
 * @id py/insecure-default-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

// 本查询通过检测未显式指定ssl_version参数的ssl.wrap_socket调用来识别SSL/TLS配置中的安全漏洞。
// 省略此参数可能导致使用不安全的默认协议，从而使应用程序面临密码学弱点。
// 有关其他协议相关的安全检查，请参考py/insecure-protocol。
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode vulnerableSslCall
where
  // 定位 ssl.wrap_socket 方法的调用
  vulnerableSslCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // 验证 ssl_version 参数是否缺失
  and not exists(vulnerableSslCall.getArgByName("ssl_version"))
select vulnerableSslCall,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."