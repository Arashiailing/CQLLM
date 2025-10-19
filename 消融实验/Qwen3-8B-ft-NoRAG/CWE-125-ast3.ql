import py

from Call c
where c.getFunction().getName() = "os.path.join"
  and (c.getArgument(0).getString().contains("..") or c.getArgument(1).getString().contains(".."))
select c, "Potential path traversal via os.path.join with.. in argument"