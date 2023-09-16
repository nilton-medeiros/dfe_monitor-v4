#include "hmg.ch"
#include <hbclass.ch>

class TApiEmpresas

    data auth protected
    data urlAPI readonly

    method new(empresa) constructor
    method Cadastrar(empresa)
    method Consultar(cnpj, tpAmb)
    method Alterar(empresa)

end class

method new(empresa) class TApiEmpresas
    ::auth := auth
return self

method Cadastrar(empresa) class TApiEmpresas
    local connect

    if empresa:tpAmb == "1"
        // API de Produção
        ::urlAPI := "https://api.nuvemfiscal.com.br"
    else
        // API de Teste
        ::urlAPI := "https://api.sandbox.nuvemfiscal.com.br"
    endif

    begin sequence
        connect := win_oleCreateObject("MSXML2.ServerXMLHTTP.6.0")
        if Empty(connect)
            saveLog("Erro na criação do serviço: MSXML2")
            consoleLog({'win_oleCreateObject("MSXML2.ServerXMLHTTP.6.0") retornou type: ', ValType(connect), hb_eol()})
            Break
        endif
    end sequence
    begin sequence

        restApi:Open("POST", url, MODO_ASSINCRONO)
        restApi:SetRequestHeader("Content-Type", content_type)

        /*  Os parâmetros são separados pelo & (ê comercial),
            mas o Harbour interpreta como macro substituição!
            Neste caso, é preciso usar o chr(38) para impor o &
            a cada parâmentro na string body
         */
        body := "grant_type=client_credentials"
        body += chr(38) + "client_id=" + client_id
        body += chr(38) + "client_secret=" + client_secret
        body += chr(38) + "scope=" + scope

        restApi:Send(body)
        restApi:WaitForResponse(5000)

    recover using objError
        msgError := MsgDebug(restApi)
        if objError:genCode != 0
            // consoleLog({"Erro de conexão com o site", hb_eol(), "Error: ", objError:description, hb_eol(), MsgDebug(restApi), hb_eol()})
            saveLog({"Erro de conexão com o site", hb_eol(), "Error: ", objError:description, hb_eol()})
        else
            // consoleLog({"Erro de conexão com o site", hb_eol(), hb_eol(), MsgDebug(restApi), hb_eol()})
            consoleLog({"Erro de conexão com o site", hb_eol(), hb_eol()})
        endif
        saveLog({"Erro de conexão com o site", hb_eol(), msgError, hb_eol()})
        Break
    end sequence

    response := restApi:ResponseBody
    // consoleLog(response)
    hResp := jsonDecode(response)
