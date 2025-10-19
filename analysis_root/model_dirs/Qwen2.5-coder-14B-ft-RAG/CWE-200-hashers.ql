/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description nan
 * @kind problem
 * @id py/hashers
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.filters.Tests
import semmle.python.dataflow.new.TaintTracking
import semmle.python.security.dataflow.WeakSensitiveDataHashingQuery

class WeakHasher extends DataFlow::Node {
  WeakHasher() {
    // 这里可以添加具体的弱哈希算法检查逻辑
    // 例如，检查是否存在非FIPS合规的哈希算法使用
  }
}

// 创建一个继承自WeakHashFlow定义的全局数据流分析模块
module HashingFlowSig = WeakHashFlow<WeakHasher, WeakHasher>;

// 定义一个谓词函数，用于判断是否存在不可信的哈希使用
predicate untrustedHashUse(ControlFlow::Node hashCall, string algorithmName) {
  // 算法名称必须符合以下条件之一：
  // 1. 是MD5或SHA1算法
  // 2. 不以'fips'开头且不是MD5或SHA1算法
  algorithmName in ["md5", "sha1"] or
  not algorithmName.regexpMatch("(?i)fips.*") and
  not algorithmName in ["md5", "sha1"]
}

// 定义一个谓词函数，用于判断是否存在不可信的哈希写入操作
predicate untrustedHashWrite(ControlFlow::Node hashCall, string algorithmName) {
  // 存在不可信的哈希使用操作，并且哈希操作没有被测试代码覆盖
  untrustedHashUse(hashCall, algorithmName) and
  not testScope(hashCall)
}

// 从哈希数据流图中的源节点和汇节点中选择数据
from HashingFlowSig::PathNode source, HashingFlowSig::PathNode sink, string algorithmName
// 条件：存在从源节点到汇节点的数据流路径，并且汇节点的哈希算法不安全
where 
  HashingFlowSig::flowPath(source, sink) and
  untrustedHashWrite(sink.getNode(), algorithmName)
// 选择汇节点、源节点、汇节点信息、哈希算法名称，并生成警告信息
select sink.getNode(),
       source,
       sink,
       "This expression uses a $@ algorithm for hashing.", 
       algorithmName,
       algorithmName.inUpperCase()