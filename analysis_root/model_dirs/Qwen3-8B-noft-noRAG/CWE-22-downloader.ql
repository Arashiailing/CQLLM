import python
import semmle.code.cpp.dataflow.DataFlow

from InputString, PathOperation
where 
  InputString.isInput() and
  PathOperation.isPathConstruction() and
  exists (InputString.getOutput().to(PathOperation.getInput()))
select PathOperation, "Uncontrolled data used in path expression"