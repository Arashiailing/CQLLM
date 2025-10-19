/**
* @name CWE-287: Improper Authentication
*
@description When an act
    or claims to have a given identity, the product does not prove
    or insufficiently proves that the claim is correct.
*
@id py/views-cwe-287
* @kind problem
* @problem.severity warning
*
@tags security * experimental * external/cwe/cwe-287
*
/// 确定精度的导入语句
import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow
// 定义一个谓词函数，用于判断是否存在不当的认证predicate improperlyAuthenticated(Call call) {
// 如果存在从任意None值到call参数的局部数据流，或者call没有设置参数，则返回true (