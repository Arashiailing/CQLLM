/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind problem
 * @id py/serializers
 * @problem.severity warning
 * @precision high
 * @security-severity 9.1
 * @tags correctness
 *       security
 *       external/cwe/cwe-20
 */

// 导入用于处理反序列化安全性的模块
import semmle.python.serialization.SerializationSecurity

// 定义查询谓词，查找潜在的安全问题
predicate unsafeSerialization(Serializer serializer) {
  // 检查是否存在未验证的反序列化操作
  exists(UnverifiedDeserialize deserialization |
    deserialization = serializer.getUnverifiedDeserialize()
  )
}

// 从序列化器和反序列化点中选择数据
from Serializer serializer, UnverifiedDeserialize deserialization
where
  // 确保存在未验证的反序列化操作
  unsafeSerialization(serializer)
  and
  // 关联反序列化点和序列化器
  deserialization = serializer.getUnverifiedDeserialize()
// 选择结果：反序列化点、序列化器、序列化器名称、描述信息
select deserialization, serializer,
  "The $@ does not validate the format of its serialized data.",
  serializer, serializer.getName()