import python

from File f, StringLiteral s
where 
  f.path.endsWith("setup.py") or 
  f.path.endsWith("config.py") or 
  f.path.endsWith(".env")
  and (s.value.contains("password") or 
       s.value.contains("secret") or 
       s.value.contains("token") or 
       s.value.contains("key"))
select f, "Potential CWE-522: Sensitive credentials stored in clear text in file " + f.path