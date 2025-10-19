```ql
import python

from Call c, Call inputCall
where (c.getCallee().getName() = "join" and c.getModule() = "os.path") or 
      (c.getCallee().getName() = "__add