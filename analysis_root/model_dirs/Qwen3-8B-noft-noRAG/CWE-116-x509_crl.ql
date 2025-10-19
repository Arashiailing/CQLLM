import python

from Call call, RegexpPattern pattern
where call.getTarget() = "re.sub"
  and call.getArg(1).getKind() = "string"
  and pattern.getRegexp() like "%<[^>]*%>"
  and exists(Call c, String s |
    c.getTarget() = "http.server.BaseHTTPRequestHandler.do_" +
                   "get" or c.getTarget() = "http.server.BaseHTTPRequestHandler.do_post"
    and s = c.getArg(1)
    and s.getStringValue() = call.getArg(0).getStringValue()
  )
select call.getLocation(), "Potential reflected XSS vulnerability due to improper HTML filtering with regex", call