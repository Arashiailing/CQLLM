import python

from Call printCall, Variable userInputVar
where 
    printCall.getTarget().getName() = "print" and 
    exists (Call inputCall | 
        inputCall.getTarget().getName() in ("input", "request.args.get", "request.form.get", "json.loads", "eval") and 
        inputCall.getResult() = userInputVar and 
        printCall.getArgument(0) = userInputVar
    ) and 
    not exists (Call escapeCall | 
        escapeCall.getTarget().getName() in ("html.escape", "cgi.escape", "xml.sax.saxutils.quoteattr") and 
        escapeCall.getArgument(0) = userInputVar
    )
select printCall, "Reflected XSS: User input directly outputted without proper escaping."