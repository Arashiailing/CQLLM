import python
import dataflow

from Call site, Argument
where call(site, "pickle.loads", [Argument])
  and dataflow::isSource(Argument)
select site, "Unsafe deserialization of user-controlled data."