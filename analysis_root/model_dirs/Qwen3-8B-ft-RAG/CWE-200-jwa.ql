import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs
import semmle.python.filters.Tests

/** * 获取Python解释器中所有内置函数的API节点集合。 */private API::Node getBuiltinFunction(string name) { exists(API::ModuleEnvironment env | env = API::builtinPythonEnv() and
  env.getMember(name) = result or
  env.getMember(name).getReturn() = result
)}

/** * 获取加密算法相关的函数或类的API节点集合。 */private API::Node getEncryptionAlgorithm(string name) {
  result = getBuiltinFunction(name)
  or
  result = getAlgorithmFromCryptography(name)
}

/** * 获取cryptography库中加密算法相关的函数或类的API节点集合。 */private API::Node getAlgorithmFromCryptography(string name) {
  result = API::moduleImport("cryptography").getMember(name).getReturn()
}

/** * 获取对加密密钥进行编码或解码的函数或类的API节点集合。 */private API::Node getEncodingOrDecoding(string name) {
  result = getEncryptionAlgorithm(name)
  or
  result = getEncodingOrDecodingFromCryptography(name)
}

/** * 获取cryptography库中编码或解码相关的函数或类的API节点集合。 */private API::Node getEncodingOrDecodingFromCryptography(string name) {
  result = API::moduleImport("cryptography").getMember("encode").getMember(name).getReturn()
  or
  result = API::moduleImport("cryptography").getMember("decode").getMember(name).getReturn()
}

/** * 获取对加密操作进行编码或解码的函数或类的API节点集合。 */private API::Node getEncodingOrDecodingOfOperation(string name) {
  result = getEncodingOrDecoding(name).(Function)
  or
  result = getEncodingOrDecodingFromCryptography(name).getACall()
}

/** * 获取对加密操作进行编码的函数或类的API节点集合。 */private API::Node getEncoding(string name) { result = getEncodingOrDecodingOfOperation(name) }

/** * 获取对加密操作进行解码的函数或类的API节点集合。 */private API::Node getDecoding(string name) { result = getEncodingOrDecodingOfOperation(name) }

/** * 获取对加密操作进行编码或解码的函数或类的API节点集合。 */private API::Node getEncodingOrDecodingOfOperation(string name, string funcName) {
  funcName = "encode"
  and
  result = getEncoding(name)
  or
  funcName = "decode"
  and
  result = getDecoding(name)
}

/** * 获取cryptography库中的jwz模块中的函数或类的API节点集合。 */private API::Node getJwzMember(string name) {
  result = API::moduleImport("cryptography").getMember("jwz").getMember(name).getReturn()
}

/** * 获取jwz模块中的函数或类的API节点集合。 */private API::Node getJwz(string name) {
  result = getJwzMember(name).(Function)
  or
  result = getJwzMember(name).getReturn()
}

/** * 获取对加密操作进行编码或解码的函数或类的API节点集合。 */private API::Node getEncodingOrDecodingOfOperation(string name, string funcName) {
  result = getJwz(name).(Function)
  or
  result = getEncodingOrDecodingOfOperation(name, funcName)
}

/** * 获取jwz模块中的函数或类的API节点集合。 */private API::Node getJwz(string name, string funcName) {
  funcName = "encode"
  and
  result = getJwzMember(name).(Function)
  or
  funcName = "decode"
  and
  result = getJwzMember(name).(Function)
}

/** * 获取jwz模块中的函数或类的API节点集合。 */private API::Node getJwz(string name, string funcName, API::ReturnStatus s) {
  s = API::singleReturn()
  and
  result = getJwz(name, funcName)
}

/** * 获取jwz模块中的函数或类的API节点集合。 */private API::Node getJwz(string name, string funcName) { result = getJwz(name, funcName, _) }

/** * 获取cryptography库中的jwz模块中的函数或类的API节点集合。 */private API::Node getJwzMember(string name, string funcName) {
  result = getJwzMember(name).(Function)
  or
  result = getJwzMember(name).getReturn()