/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @id py/store_invite_servlet
 */

import python
import semmle.python.security.dataflow.UncontrolledResourceConsumptionQuery

from Call call, ClassValue resClass
where
  call.getFunc().pointsTo(resClass) and
  resClass.getASuperType() = ClassValue::resource() and
  not exists(ExprStmt s | s.getValue() = call)
select call, "This resource allocation may consume an unlimited amount of a limited resource."