#include "hmg.ch"
#include <hbclass.ch>
#define MODO_ASSINCRONO .F.

class TNuvemFiscal

    data token readonly
    data expires_in readonly
    data Authorized readonly

    method new() constructor
    method getNewToken()

end class

method new() class TNuvemFiscal
    static twoDaysBefore := 172800

    ::token := CharXor(RegistryRead(::winRegistryPath + "nuvemFiscal\token"), "SysWeb2023")
    ::expires_in := RegistryRead(::winRegistryPath + "nuvemFiscal\expires_in")

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
    local restApi, body, response, hToken
    local content_type := ""application/x-www-form-urlencoded""
    local grant_type := "client_credentials"
    local client_id := empresa:nuvemfiscal_client_id
    local client_secret := empresa:nuvemfiscal_client_secret
    local escope := "cte mdfe cnpj"
    local hResp

    try
        restApi := win_oleCreateObject("MSXML2.ServerXMLHTTP.6.0")
    catch
        saveLog("Erro na criação do serviço: MSXML2")
        consoleLog({'win_oleCreateObject("MSXML2.ServerXMLHTTP.6.0") retornou type: ', ValType(restApi)})
        return false
    end
    try
        restApi:Open("POST", url, MODO_ASSINCRONO)
        restApi:SetRequestHeader("Content-Type", content_type)
        restApi:SetRequestHeader("grant_type", grant_type)
        restApi:SetRequestHeader("client_id", client_id)
        restApi:SetRequestHeader("client_secret", client_secret)
        restApi:SetRequestHeader("escope", escope)
        restApi:Send()
        restApi:WaitForResponse(5000)
    catch
        saveLog("Erro de conexão com o site")
        consoleLog({"Erro de conexão com o site", hb_eol(), MsgDebug(restApi)})
        return false
    end

    response := restApi:ResponseBody
    consoleLog(response)
    hResp := jsonDecode(response)

    if hb_HGetRef(hResp, "access_token")
        ::token := hResp["access_token"]
        ::expires_in := Seconds() + hResp["expires_in"]
        RegistryWrite(::winRegistryPath + "nuvemFiscal\token", CharXor(::token, "SysWeb2023"))
        RegistryWrite(::winRegistryPath + "nuvemFiscal\expires_in", ::expires_in)
        lAuth := true
    else
        consoleLog({"O responseBody (hResp) retornou vazio", hb_eol(), MsgDebug(hResp)})
    endif

return lAuth