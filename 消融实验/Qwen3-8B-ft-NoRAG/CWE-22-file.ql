import py

from Call call
where call.getCallee() = "os.path.join" or
      call.getCallee() = "Path.__truediv__" or
      call.getFunctionName() = "str.__add__" or
      call.getFunctionName() = "str.format"
select call, "Potential path injection via uncontrolled data in path expression"