/**
 * @name Decompression Bomb
 * @description Uncontrolled data that flows into decompression library APIs without checking the compression rate is dangerous
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision high
 * @id py/decompression-bomb
 * @tags security
 *       experimental
 *       external/cwe/cwe-409
 */

// 导入Python库，用于分析Python代码
import python
// 导入实验性的Python安全分析模块中的DecompressionBomb类
import experimental.semmle.python.security.DecompressionBomb
// 导入路径图模块，用于数据流分析
import BombsFlow::PathGraph

// 从路径图中选择源节点和汇节点
from BombsFlow::PathNode source, BombsFlow::PathNode sink
// 条件：存在从源节点到汇节点的流动路径
where BombsFlow::flowPath(source, sink)
// 选择汇节点、源节点及其相关信息，并生成警告信息
select sink.getNode(), source, sink, "This uncontrolled file extraction is $@.", source.getNode(),
  // 警告信息：未受控的文件解压依赖于用户控制的数据
  "depends on this user controlled data"
