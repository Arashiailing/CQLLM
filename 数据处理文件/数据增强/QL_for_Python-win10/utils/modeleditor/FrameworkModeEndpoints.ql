/**
 * @name Fetch endpoints for use in the model editor (framework mode)
 * @description A list of endpoints accessible (methods and attributes) for consumers of the library. Excludes test and generated code.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

// 导入ModelEditor模块，用于模型编辑功能
import modeling.ModelEditor

// 从Endpoint类中选择所需的字段，生成一个表格形式的查询结果
from Endpoint endpoint
select 
  // 选择endpoint对象本身
  endpoint,
  // 获取endpoint的命名空间
  endpoint.getNamespace(),
  // 获取endpoint所属的类
  endpoint.getClass(),
  // 获取endpoint对应的函数名称
  endpoint.getFunctionName(),
  // 获取endpoint的参数列表
  endpoint.getParameters(),
  // 获取endpoint支持的状态
  endpoint.getSupportedStatus(),
  // 获取定义endpoint的文件名
  endpoint.getFileName(),
  // 获取endpoint支持的类型
  endpoint.getSupportedType(),
  // 获取endpoint的种类
  endpoint.getKind()
