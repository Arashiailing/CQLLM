import python

from Variable var
where var.isGlobal() and (var.getName() like '%password%' or var.getName() like '%secret%' or var.getName() like '%key%' or var.getName() like '%token%')
select var, "Global variable stores sensitive data in cleartext."

from Assignment assign
where assign.getLValue().isGlobal() and assign.getRValue().isStringLiteral() and assign.getRValue().getValue() like '%password%' or assign.getRValue().getValue() like '%secret%' or assign.getRValue().getValue() like '%key%' or assign.getRValue().getValue() like '%token%'
select assign, "Global variable stores sensitive data in cleartext."

from FileWrite write
where write.getContent().isStringLiteral() and write.getContent().getValue() like '%password%' or write.getContent().getValue() like '%secret%' or write.getContent().getValue() like '%key%' or write.getContent().getValue() like '%token%'
select write, "Sensitive data written to file in cleartext."

from LogMessage log
where log.getMessage().isStringLiteral() and log.getMessage().getValue() like '%password%' or log.getMessage().getValue() like '%secret%' or log.getMessage().getValue() like '%key%' or log.getMessage().getValue() like '%token%'
select log, "Sensitive data logged in cleartext."