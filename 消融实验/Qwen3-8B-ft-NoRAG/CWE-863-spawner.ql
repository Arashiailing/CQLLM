import python

from Call call, IfStmt ifStmt
where call.getCallee().getName() = "has_permission" and
      ifStmt.getCondition() = call
select ifStmt, "Potential incorrect authorization check due to negation of permission check."