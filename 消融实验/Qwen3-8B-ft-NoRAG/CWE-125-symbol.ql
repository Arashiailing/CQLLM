import python

from Access access
where access.getKind() = "index"
  and (access.getBase().getType().isList() or access.getBase().getType().isString())
select access, "Potential out-of-bounds read due to index access"