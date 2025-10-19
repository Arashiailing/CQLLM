import py

from CallExpr c
where
  (c.getFunction().getName() = "os.system" and
   c.getArgument(0).getType().isString() and
   c.getArgument(0).isVariable()) or
  (c.getFunction().getName() = "subprocess.run" and
   c.getArgument(1).isMap() and
   c.getArgument(1).getEntry(0).getKey().getName() = "shell" and
   c.getArgument(1).getEntry(0).getValue().isBool() and
   c.getArgument(1).getEntry(0).getValue().getValue() = true and
   c.getArgument(0).getType().isString() and
   c.getArgument(0).isVariable()) or
  (c.getFunction().getName() in ["eval", "exec"] and
   c.getArgument(0).getType().isString() and
   c.getArgument(0).isVariable())
select c, "Potential command injection due to unvalidated input"