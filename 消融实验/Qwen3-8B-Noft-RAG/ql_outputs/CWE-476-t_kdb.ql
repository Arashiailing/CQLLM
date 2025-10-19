import python
import semmle.python.pointsto.PointsTo

from Expr e
where points_to_failure(e)
  and e.hasAttributeAccess()
  or e.hasMethodCall()
select e, "Potential NULL pointer dereference"