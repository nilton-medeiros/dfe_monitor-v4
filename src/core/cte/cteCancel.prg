#include "hmg.ch"

procedure cteCancel(cte)
    local apiCTe := TApiCTe():new(cte)
    local registrado
    local targetFile, anoEmes, directory, aError, error

    consoleLog({"Cancelando CTe: ", cte:chCTe, ", nuvemfiscal_uuid: ", apiCTe:nuvemfiscal_uuid})

    if apiCTe:Cancelar()

        // Prepara os campos da tabela ctes para receber os updates
        if (apiCTe:codigo_status == 135)
            cte:setSituacao("CANCELADO")
            consoleLog({"CTe: ", apiCTe:chave, " cancelado com sucesso, pegando PDF e XML de Cancelamento"})
            cteGetFiles(cte, apiCTe)
        else
            cte:setSituacao(apiCTe:status)
        endif

        // Prepara os campos da tabela ctes_eventos para receber os updates
        if !Empty(apiCTe:motivo_status)
            cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, apiCTe:codigo_status, apiCTe:motivo_status)
            if !Empty(apiCTe:tipo_evento)
                mdfe:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, apiCTe:codigo_status, "Tipo Evento: " + apiCTe:tipo_evento)
            endif
        endif
        if !Empty(apiCTe:mensagem)
            cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_recebimento, apiCTe:codigo_mensagem, apiCTe:mensagem)
            if !Empty(apiCTe:tipo_evento)
                mdfe:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_recebimento, apiCTe:codigo_mensagem, "Tipo Evento: " + apiCTe:tipo_evento)
            endif
        endif

        consoleLog({"Evento de Cancelamento Registrado", hb_eol(), "apiCTe:status " + apiCTe:status, hb_eol(), ;
                    "cStat: ", iif(!Empty(apiCTe:codigo_status), apiCTe:codigo_status, apiCTe:codigo_mensagem)})

    else
        aError := getMessageApiError(apiCTe, false)
        for each error in aError
            cte:setUpdateEventos("Erro", date_as_DateTime(date(), false, false), error["code"], error["message"])
        next
        cte:setSituacao(apiCTe:status)
        consoleLog("Erro ao cancelar: apiCTe:response" + apiCTe:response)
    endif

return
