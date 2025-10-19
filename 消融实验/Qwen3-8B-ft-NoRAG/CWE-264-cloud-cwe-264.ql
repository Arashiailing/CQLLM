import python

from FileWrite fw, VariableUse vu, VariableAssignment va
where fw.get_value() = vu.get_value() 
  and (va.get_variable() like "password%" or va.get_variable() like "secret%" or va.get_variable() like "key%" or va.get_variable() like "token%")
select fw, "Potential CWE-264: Cleartext storage of sensitive data in file"

from Call call
where call.getCallee() = "sqlite3.Connection.execute" 
  and call.getArg(0) is not null 
  and call.getArg(0).get_string_value() is not null
select call, "Potential CWE-264: Cleartext storage in database"