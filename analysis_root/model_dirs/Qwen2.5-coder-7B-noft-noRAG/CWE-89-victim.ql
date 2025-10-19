import python // 导入Python库，用于分析Python代码
import semmle.python.security.dataflow.SqlInjectionQuery // 导入SQL注入查询相关的数据流分析库
import SqlInjectionFlow::PathGraph // 导入SqlInjection路径图类，用于表示数据流路径

// 从SqlInjection路径图中选择源节点和汇节点
from SqlInjectionFlow::PathNode source, SqlInjectionFlow::PathNode sink
where SqlInjectionFlow::flowPath(source, sink) // 条件：存在从源节点到汇节点的路径
select sink.getNode(), source, sink, "This SQL query depends on a $@.", source.getNode(), "user-provided value" // 选择结果：汇节点、源节点、路径信息以及描述信息