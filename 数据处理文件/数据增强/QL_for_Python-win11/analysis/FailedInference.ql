import python  # 导入Python库，用于分析Python代码
import semmle.python.pointsto.PointsTo  # 导入Semmle的PointsTo分析模块，用于指向分析

# 从ClassValue类中选择cls和reason字段
from ClassValue cls, string reason
# 条件是Types::failedInference(cls, reason)为真
where Types::failedInference(cls, reason)
# 选择符合条件的cls和reason
select cls, reason
