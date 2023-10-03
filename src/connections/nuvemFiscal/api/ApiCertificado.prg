#include "hmg.ch"
#include <hbclass.ch>


class TApiCertificado

    data cnpj readonly
    data token
    data connection 
    data connected readonly
    data response readonly
    data httpStatus readonly
    data ContentType readonly

    method new(cnpj) constructor
    method Consultar()
    method Cadastrar(certificado, password)
    method Deletar()

end class


method new(cnpj) class TApiCertificado

    ::cnpj := cnpj
    ::connected := false
    ::response := ""
    ::httpStatus := 0
    ::ContentType := ""
    ::token := appNuvemFiscal:token

    if Empty(::token)
        saveLog("Token vazio para conexão com a Nuvem Fiscal")
    else
        ::connection := GetMSXMLConnection()
        ::connected := !Empty(::connection)
    endif

return self


method Consultar() class TApiCertificado
    local res, apiUrl

    if !::connected
        return false
    endif

    // Debug: Integração em teste, remover os comentários do laço if/endif abaixo
    // if empresa:tpAmb == 1
        // API de Produção
        // apiUrl := "https://api.nuvemfiscal.com.br/empresas/" + ::cnpj + "/certificado"
    // else
        // API de Teste
        apiUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas/" + ::cnpj + "/certificado"
    // endif

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type
    res := Broadcast(::connection, "GET", apiUrl, ::token, "Consultar Certificado")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao consultar certificado na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(), "Content-Type: ", res['ContetType'], hb_eol(), "Response: ", res['response']})
    endif

return !res['error']


method Cadastrar(certificado, password) class TApiCertificado
    local res, apiUrl, body

    if !::connected
        return false
    endif

    // Integração em teste, remover os comentários do laço if/endif abaixo
    // if empresa:tpAmb == 1
        // API de Produção
        // apiUrl := "https://api.nuvemfiscal.com.br/empresas/" + ::cnpj + "/certificado"
    // else
        // API de Teste
        apiUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas/" + ::cnpj + "/certificado"
    // endif

    // Request Body
    body := '{' + hb_eol()
    body += '  "certificado": "' + certificado + '",' + hb_eol()
    body += '  "password": "' + password + '"' + hb_eol()
    body += '}'

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type
    res := Broadcast(::connection, "PUT", apiUrl, ::token, "Cadastrar Certificado", body)

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao cadastrar certificado na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
                 "ContentType: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
    endif

return !res['error']


method Deletar() class TApiCertificado
    local apiUrl, res
    // Integração em teste, remover os comentários do laço if/endif abaixo
    // if empresa:tpAmb == 1
        // API de Produção
        // apiUrl := "https://api.nuvemfiscal.com.br/empresas/" + ::cnpj + "/certificado"
    // else
        // API de Teste
        apiUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas/" + ::cnpj + "/certificado"
    // endif

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type
    res := Broadcast(::connection, "DELETE", apiUrl, ::token, "Deletar Certificado")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao deletar certificado na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(), "Content-Type: ", res['ContetType'], hb_eol(), "Response: ", res['response']})
    endif

return !res['error']
