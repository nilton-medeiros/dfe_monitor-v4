#include "hmg.ch"
#include <hbclass.ch>

#define MODO_ASSINCRONO .F.

class TNuvemFiscal

    data token readonly
    data expires_in readonly
    data Authorized readonly
    data regPath protected

    method new() constructor
    method getNewToken()

end class

method new() class TNuvemFiscal
    static twoDaysBefore := 172800

    ::regPath := appData:winRegistryPath
    ::token := CharXor(RegistryRead(::regPath + "nuvemFiscal\token"), "SysWeb2023")
    ::expires_in := RegistryRead(::regPath + "nuvemFiscal\expires_in")

    if Empty(::expires_in) .or. (::expires_in > Seconds()-twoDaysBefore)
        ::Authorized := ::getNewToken()
    else
        ::Authorized := true
    endif

return Self

method getNewToken() class TNuvemFiscal
    local lAuth := false
    local empresa := appEmpresas:empresas[1]
    local url := "https://auth.nuvemfiscal.com.br/oauth/token"
    local restApi, response
	local content_type := "application/x-www-form-urlencoded"
    local client_id := empresa:nuvemfiscal_client_id
    local client_secret := empresa:nuvemfiscal_client_secret
    local scope := "cte mdfe cnpj"
    local hResp
    local objError, msgError
    local body

    begin sequence
        restApi := win_oleCreateObject("MSXML2.ServerXMLHTTP.6.0")
        if Empty(restApi)
            saveLog("Erro na criação do serviço: MSXML2")
            consoleLog({'win_oleCreateObject("MSXML2.ServerXMLHTTP.6.0") retornou type: ', ValType(restApi)})
            Break
        endif
    end sequence
    begin sequence
        restApi:Open("POST", url, MODO_ASSINCRONO)
        restApi:SetRequestHeader("Content-Type", content_type)

        body := "grant_type=client_credentials"
        body += chr(38) + "client_id=" + client_id
        body += chr(38) + "client_secret=" + client_secret
        body += chr(38) + "scope=" + scope

        restApi:Send(body)
        restApi:WaitForResponse(5000)
    recover using objError
        msgError := MsgDebug(restApi)
        if objError:genCode != 0
            consoleLog({"Erro de conexão com o site", hb_eol(), "Error: ", objError:description, hb_eol(), MsgDebug(restApi)})
        else
            consoleLog({"Erro de conexão com o site", hb_eol(), hb_eol(), MsgDebug(restApi)})
        endif
        saveLog({"Erro de conexão com o site", hb_eol(), msgError})
        Break
    end sequence

    response := restApi:ResponseBody
    consoleLog(response)
    hResp := jsonDecode(response)

    if hb_HGetRef(hResp, "access_token")
        ::token := hResp["access_token"]
        ::expires_in := Seconds() + hResp["expires_in"]
        RegistryWrite(::regPath + "nuvemFiscal\token", CharXor(::token, "SysWeb2023"))
        RegistryWrite(::regPath + "nuvemFiscal\expires_in", ::expires_in)
        lAuth := true
    else
        msgError := MsgDebug(response, hResp)
        consoleLog({"ResponseBody (hResp) retornou vazio", hb_eol(), msgError})
        saveLog("Falha na autenticação com a API da NuvemFiscal, o responseBody (hResp) retornou vazio")
    endif

return lAuth