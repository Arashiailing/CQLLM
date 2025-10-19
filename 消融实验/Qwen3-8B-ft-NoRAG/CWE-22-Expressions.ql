import py

from Call c
where (c.getFunction().getName() = "os.path.join" or
       c.getFunction().getName() = "pathlib.Path.__add__" or
       c.getFunction().getName() = "pathlib.Path.__truediv__") and
      (c.getArgument(0).hasType("str") or c.getArgument(1).hasType("str")) and
      (c.getArgument(0).toString().contains("..") or
       c.getArgument(1).toString().contains(".."))
select c, "Potential path injection due to uncontrolled data in path expression."