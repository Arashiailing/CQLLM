import python

from Call call, StringConcat stringConcat, Assign assign
where
  call.getTarget().getName() = "execute" and
  call.getCallee().getQualifiedName() = "sqlite3.Cursor.execute" and
  call.getArgument(0).getValue() = stringConcat and
  exists(assign) where
    assign.getLeft().getName() = stringConcat and
    (assign.getRight().getType().isString() or
     assign.getRight().getType().isArray())
select call.getLocation(), "Potential SQL injection via string concatenation in execute call"