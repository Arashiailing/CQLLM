import python

from ArrayAccess aa
where
  (aa.index.ge(py.len(aa.array)) or aa.index.le(-py.len(aa.array)))
select aa, "Potential buffer overflow due to out-of-bounds array access."