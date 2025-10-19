import python

from Call c, StringConcatenation sc
where c.getFunction().getName() in ["open", "os.path.join", "os.system", "subprocess.check_output", "shlex.split"]
  and c.getArgument(0) = sc
select c, "Potential Path Injection due to string concatenation in file path."