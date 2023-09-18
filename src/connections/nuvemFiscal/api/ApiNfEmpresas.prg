#include "hmg.ch"
#include <hbclass.ch>
#define MODO_ASSINCRONO .F.

class TApiNfEmpresas

    data token protected
    data apiUrl readonly
    data connection protected
    data connected readonly
    data httpMethod protected
    data body readonly
    data responseBody readonly
    data responseText readonly
    data responseStatus readonly

    method new() constructor
    method Cadastrar(empresa)
    // method Consultar(empresa)
    // method Alterar(empresa)
    method defineBody(empresa)
    method Broadcast()

end class

method new() class TApiNfEmpresas
    ::connected := false
    begin sequence
        ::connection := win_oleCreateObject("MSXML2.ServerXMLHTTP.6.0")
        if Empty(::connection)
            saveLog("Erro na criação do serviço: MSXML2")
            consoleLog({'win_oleCreateObject("MSXML2.ServerXMLHTTP.6.0") retornou type: ', ValType(connect), hb_eol()})
            Break
        endif
        ::token := appNuvemFiscal:token
        if Empty(::token)
            saveLog("Token vazio para conexão com a Nuvem Fiscal")
        else
            ::connected := true
        endif
    end sequence
return self

method Cadastrar(empresa) class TApiNfEmpresas

    if !::connected
        return false
    endif

    ::httpMethod := "POST"

    // Integração em teste, remover os comentários do laço if/endif abaixo
    consoleLog("Cadastrando empresa em Nuvem Fiscal modo teste (sandbox)")
    // if empresa:tpAmb == "1"
        // API de Produção
        // ::apiUrl := "https://api.nuvemfiscal.com.br/empresas"
    // else
        // API de Teste
        ::apiUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas"
    // endif

    ::defineBody(empresa)   // Prepara o json text
    // Broadcast: Transmitir solicitação a API da Nuvem Fiscal
return ::Broadcast("CADASTRAR")

/* defineBody: Utilizado pelos métodos Cadastrar e Alterar */
method defineBody(empresa) class TApiNfEmpresas
    // body: Json com as informações da empresa
    ::body := '{' + hb_eol()
    ::body += '  "cpf_cnpj": "' + empresa:cnpj + '",' + hb_eol()
    ::body += '  "inscricao_estadual": "' + empresa:IE + '",' + hb_eol()
    ::body += '  "inscricao_municipal": "' + empresa:IM + '",' + hb_eol()
    ::body += '  "nome_razao_social": "' + empresa:xNome + '",' + hb_eol()
    ::body += '  "nome_fantasia": "' + empresa:xFant + '",' + hb_eol()
    ::body += '  "fone": "' + empresa:fone + '",' + hb_eol()
    ::body += '  "email": "' + empresa:email + '",' + hb_eol()
    ::body += '  "endereco": {' + hb_eol()
    ::body += '    "logradouro": "' + empresa:xLgr + '",' + hb_eol()
    ::body += '    "numero": "' + empresa:nro + '",' + hb_eol()
    ::body += '    "complemento": "' + empresa:xCpl + '",' + hb_eol()
    ::body += '    "bairro": "' + empresa:xBairro + '",' + hb_eol()
    ::body += '    "codigo_municipio": "' + empresa:cMunEnv + '",' + hb_eol()
    ::body += '    "cidade": "' + empresa:xMunEnv + '",' + hb_eol()
    ::body += '    "uf": "' + empresa:UF + '",' + hb_eol()
    ::body += '    "cep": "' + empresa:CEP + '"' + hb_eol()
    ::body += '  }' + hb_eol()
    ::body += '}'
return nil

/*
    Broadcast: Transmitir
    Transmite à API da Nuvem Fiscal a solicitação (endpoint) e json
    (body) de acordo com o método http solicitado.
*/
method Broadcast(operation) class TApiNfEmpresas
    local objError, msgError, lError := false

    begin sequence
        ::connection:Open(::httpMethod, ::apiUrl, MODO_ASSINCRONO)
        ::connection:SetRequestHeader("Authorization", "Bearer " + ::token)
        ::connection:SetRequestHeader("Content-Type", "application/json")
        ::connection:Send(::body)
        ::connection:WaitForResponse(5000)
    recover using objError
        msgError := MsgDebug(::connection)
        if objError:genCode != 0
            // consoleLog({"Erro de conexão com o site", hb_eol(), "Error: ", objError:description, hb_eol(), msgError, hb_eol()})
            saveLog({"Erro de conexão com o site em " + operation + " Empresa", hb_eol(), "Error: ", objError:description, hb_eol()})
        else
            // consoleLog({"Erro de conexão com o site", hb_eol(), hb_eol(), msgError, hb_eol()})
            saveLog({"Erro de conexão com o site em " + operation + " Empresa", hb_eol(), msgError, hb_eol(), hb_eol()})
        endif
        lError := true
        Break
    end sequence

    ::responseBody := ""
    ::responseText := ""

    if !lError
        lError := true
        ::responseStatus := ::connection:Status
        if (::connection:Status > 199) .and. (::connection:Status < 300)
            // Entre 200 e 299
            ::responseBody := ::connection:ResponseBody
            lError := false
        elseif (::connection:Status > 399) .and. (::connection:Status < 600)
            consoleLog({operation + " empresa | ", "Status: ", ::connection:Status, hb_eol(), "responseBody: ", ::connection:getResponseHeader("Context-Type")})
            consoleLog({hb_eol(), "Conteúdo do objeto ::connection: ", msgError})
            if (["error": {] $ ::connection:ResponseBody)
                // "application/json"
                ::responseBody := ::connection:ResponseBody
            else
                // "application/text"
                ::responseText := ::connection:ResponseText
            endif
        endif
    endif

return !lError
