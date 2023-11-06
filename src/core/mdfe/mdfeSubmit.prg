#include "hmg.ch"

procedure mdfeSubmit(mdfe)
    local apiMDFe := TApiMDFe():new(mdfe)
    local startTimer, recebido, emitido
    local targetFile, anoEmes, directory, aError, error

    recebido := apiMDFe:Emitir()
    emitido := false

    if recebido

        // Se mdfe foi recebido, verifica se foi autorizado, rejeitado ou se ainda está pendente (aguardando na fila para ser processado)
        emitido := (apiMDFe:status == "autorizado")

        if !emitido
            // Normalmente em produção a api da Nuvem Fiscal retorna status "pendente" segundo orientação da nv, nos testes (homologação) retornaram direto 'autorizado'
            sysWait(2)  // Aguarda 2 segundos para obter autorizado ou erro
            startTimer := Seconds()
            do while apiMDFe:Consultar() .and. (apiMDFe:status == 'pendente') .and. (Seconds() - startTimer < 10)
                // Situação pouco provável, porem não impossível: Insiste obter informações por até 10 segundos
                sysWait(2)
            enddo
            emitido := (apiMDFe:status == "autorizado")
        endif

        if emitido

            // Prepara os campos da tabela mdfes para receber os updates
            mdfe:setSituacao(apiMDFe:status)
            mdfe:setUpdateMDFe('cMDF', apiMDFe:chave)
            mdfe:setUpdateMDFe('nProt', apiMDFe:numero_protocolo)
            mdfe:setUpdateMDFe('nuvemfiscal_uuid', apiMDFe:nuvemfiscal_uuid)

            // Prepara os campos da tabela mdfes_eventos para receber os updates
            if !Empty(apiMDFe:motivo_status)
                mdfe:setUpdateEventos(apiMDFe:numero_protocolo, apiMDFe:data_evento, apiMDFe:codigo_status, apiMDFe:motivo_status)
            endif
            if !Empty(apiMDFe:mensagem)
                mdfe:setUpdateEventos(apiMDFe:numero_protocolo, apiMDFe:data_recebimento, apiMDFe:codigo_mensagem, apiMDFe:mensagem)
            endif

        endif

    endif

    if emitido
        mdfeGetFiles(mdfe, apiMDFe)
    else
        aError := getMessageApiError(apiMDFe, false)
        for each error in aError
            mdfe:setUpdateEventos("Erro", date_as_DateTime(date(), false, false), error["code"], error["message"])
        next
        mdfe:setSituacao("ERRO")
    endif

return
