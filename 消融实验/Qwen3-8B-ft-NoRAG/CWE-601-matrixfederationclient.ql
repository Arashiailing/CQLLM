import python

from Call import Call
from Function import Function
from Parameter import Parameter
from StringLiteral import StringLiteral
from Variable import Variable

// Define potential URL construction functions
Function getFunction = Function("get", "requests")
Function requestFunction = Function("request", "http.client")
Function urlopenFunction = Function("urlopen", "urllib.request")
Function redirectFunction = Function("redirect", "flask")

// Check for URL redirection in requests.get
Call getCall where getCall.getFunction() = getFunction
Parameter getUrlParam = getCall.getParameter(1)
if getUrlParam.getType().isString() and getUrlParam.getValue() is not StringLiteral then
  select getUrlParam, "Potential URL redirection with unvalidated user input in requests.get"

// Check for URL redirection in http.client.request
Call requestCall where requestCall.getFunction() = requestFunction
Parameter requestUrlParam = requestCall.getParameter(1)
if requestUrlParam.getType().isString() and requestUrlParam.getValue() is not StringLiteral then
  select requestUrlParam, "Potential URL redirection with unvalidated user input in http.client.request"

// Check for URL redirection in urllib.request.urlopen
Call urlopenCall where urlopenCall.getFunction() = urlopenFunction
Parameter urlParam = urlopenCall.getParameter(0)
if urlParam.getType().isString() and urlParam.getValue() is not StringLiteral then
  select urlParam, "Potential URL redirection with unvalidated user input in urllib.request.urlopen"

// Check for URL redirection in Flask.redirect
Call redirectCall where redirectCall.getFunction() = redirectFunction
Parameter redirectUrlParam = redirectCall.getParameter(0)
if redirectUrlParam.getType().isString() and redirectUrlParam.getValue() is not StringLiteral then
  select redirectUrlParam, "Potential URL redirection with unvalidated user input in Flask.redirect"