import py

from Call c
where c.getCallee().getName() in ["eval", "exec", "subprocess.run", "subprocess.call"]
select c, "Potential code injection via code execution functions"