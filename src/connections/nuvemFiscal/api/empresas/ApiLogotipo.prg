#include "hmg.ch"
#include <hbclass.ch>


class TApiLogotipo

    data cnpj readonly
    data token
    data connection
    data connected readonly
    data response readonly
    data httpStatus readonly
    data ContentType readonly

    method new(cnpj) constructor
    method Baixar()
    method Enviar(imgLogotipo)
    method Deletar()

end class


method new(cnpj) class TApiLogotipo

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


method Baixar() class TApiLogotipo
    local res, apiUrl

    if !::connected
        return false
    endif

    // Debug: Integração em teste, remover os comentários do laço if/endif abaixo
    // if empresa:tpAmb == 1
        // API de Produção
        // apiUrl := "https://api.nuvemfiscal.com.br/empresas/" + ::cnpj + "/logotipo"
    // else
        // API de Teste
        apiUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas/" + ::cnpj + "/logotipo"
    // endif

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "GET", apiUrl, ::token, "Baixar Logotipo")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao baixar logotipo na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(), "Content-Type: ", res['ContetType'], hb_eol(), "Response: ", res['response']})
    endif

return !res['error']


method Enviar(imgLogotipo, cExt) class TApiLogotipo
    local res, apiUrl, content_type := "image/png"

    if !::connected
        return false
    endif

    default cExt := "png"

    // Integração em teste, remover os comentários do laço if/endif abaixo
    // if empresa:tpAmb == 1
        // API de Produção
        // apiUrl := "https://api.nuvemfiscal.com.br/empresas/" + ::cnpj + "/logotipo"
    // else
        // API de Teste
        apiUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas/" + ::cnpj + "/logotipo"
    // endif

    cExt := Token(cExt, ".")
    content_type := "multipart/form-data"

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "PUT", apiUrl, ::token, "Enviar Logotipo", imgLogotipo, content_type)

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao enviar logotipo na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
                 "ContentType: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
    endif

return !res['error']


method Deletar() class TApiLogotipo
    local apiUrl, res
    // Integração em teste, remover os comentários do laço if/endif abaixo
    // if empresa:tpAmb == 1
        // API de Produção
        // apiUrl := "https://api.nuvemfiscal.com.br/empresas/" + ::cnpj + "/logotipo"
    // else
        // API de Teste
        apiUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas/" + ::cnpj + "/logotipo"
    // endif

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "DELETE", apiUrl, ::token, "Deletar Logotipo")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao deletar logotipo na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(), "Content-Type: ", res['ContetType'], hb_eol(), "Response: ", res['response']})
    endif

return !res['error']
