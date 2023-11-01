#include "hmg.ch"

procedure mdfeClose(mdfe)
    local apiMDFe := TApiMDFe():new(mdfe)
    local aError, error

    // Debug:
    consoleLog({"Encerrar MDFe: ", mdfe:chave, ", nuvemfiscal_uuid: ", apiMDFe:nuvemfiscal_uuid})

    if apiMDFe:Encerrar()

        // Prepara os campos da tabela mdfes para receber os updates
        if (apiMDFe:codigo_status == 135)
            mdfe:setSituacao("ENCERRADO")
            // Debug:
            consoleLog({"MDFe: ", apiMDFe:chave, " encerrado com sucesso, pegando PDF e XML de Encerramento"})
            mdfeGetFiles(mdfe, apiMDFe)
        else
            mdfe:setSituacao(apiMDFe:status)
        endif

        // Prepara os campos da tabela mdfes_eventos para receber os updates
        if !Empty(apiMDFe:motivo_status)
            mdfe:setUpdateEventos(apiMDFe:numero_protocolo, apiMDFe:data_evento, apiMDFe:codigo_status, apiMDFe:motivo_status)
            if !Empty(apiMDFe:tipo_evento)
                mdfe:setUpdateEventos(apiMDFe:numero_protocolo, apiMDFe:data_evento, apiMDFe:codigo_status, "Tipo Evento: " + apiMDFe:tipo_evento)
            endif
        endif
        if !Empty(apiMDFe:mensagem)
            mdfe:setUpdateEventos(apiMDFe:numero_protocolo, apiMDFe:data_recebimento, apiMDFe:codigo_mensagem, apiMDFe:mensagem)
            if !Empty(apiMDFe:tipo_evento)
                mdfe:setUpdateEventos(apiMDFe:numero_protocolo, apiMDFe:data_recebimento, apiMDFe:codigo_mensagem, "Tipo Evento: " + apiMDFe:tipo_evento)
            endif
        endif

        consoleLog({"Evento de Encerramento Registrado", hb_eol(), "apiMDFe:status " + apiMDFe:status, hb_eol(), "cStat: ", iif(!Empty(apiMDFe:codigo_status), apiMDFe:codigo_status, apiMDFe:codigo_mensagem)})   // Debug

    else
        aError := getMessageApiError(apiMDFe, false)
        for each error in aError
            mdfe:setUpdateEventos("Erro", date_as_DateTime(date(), false, false), error["code"], error["message"])
        next
        mdfe:setSituacao(apiMDFe:status)
        // Debug:
        consoleLog("Erro ao encerrar: apiMDFe:response" + apiMDFe:response)
    endif

return
