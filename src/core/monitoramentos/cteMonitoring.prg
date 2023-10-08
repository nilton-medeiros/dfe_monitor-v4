#include "hmg.ch"

procedure cteMonitoring()
    local cte, ctes := TDbConhecimentos():new()
    local emTeste := true // Remover esta linha após testes

    ctes:getListCTes()

    if (ctes:count == 0)
        return // Não retornou CTEs para transmitir a Sefaz
    endif

    for each cte in ctes:ctes
        // Testes: remover esta variável "emTeste" e o "if emTeste" após testes
        if emTeste
            // Os CTes de 44501 à 44506 são dados reais e vem do banco de dados e serao processados no ambiente de homologação
            // cteSubmit(cte)
            cteGetFiles(cte)
            // cteCancel(cte)
        else
            switch cte:monitor_action
                case "SUBMIT"
                    cteSubmit(cte)
                    exit
                case "GETFILES"
                    cteGetFiles(cte)
                    exit
                case "CANCEL"
                    cteCancel(cte)
                    exit
            endswitch
            DO EVENTS
        endif
    next

    // Testes - remover essas linhas abaixo
    PlayOk()
    MsgInfo({'getSubmit: OK', hb_eol(), 'getGetFiles: OK', hb_eol(),'getCancel: OK', hb_eol(), "Ver log do sistema."}, "Testes Concluídos")
    saveLog("Fim dos testes, desligamento do sistema automático.")
    turnOFF()

return

// Debug: Para converter o binary DACTE-PDF e XML recebidos no Json, Usar: hb_MemoWrit( <cFileName>, <cString>) ➜ lSuccess

procedure cteSubmit(cte)
    local apiCTe := TApiCTe():new(cte)
    local startTimer, consultouCTe := false, empresa
    local targetFile, anoEmes, directory, aError, error

    if apiCTe:Emitir()

        consoleLog("Processando Emitir(cte) | apiCTe:status " + apiCTe:status)   // Debug

        if (apiCTe:status == "autorizado")
            consultouCTe := true
        else
            sysWait(2)  // Aguarda 2 segundos para obter autorizado ou erro
            consultouCTe := apiCTe:Consultar()
            startTimer := Seconds()

            do while consultouCTe .and. (apiCTe:status == 'pendente') .and. (Seconds() - startTimer < 10)
                // Situação pouco provável, porem não impossível: Insiste obter informações por até 10 segundos
                sysWait(2)
                consultouCTe := apiCTe:Consultar()
            enddo

            consoleLog("consultouCTe: " + iif(consultouCTe, "SIM", "NÃO"))  // Debug

        if consultouCTe

            // Prepara os campos da tabela ctes para receber os updates
            cte:setSituacao(apiCTe:status)
            cte:setUpdateCte('cte_chave', apiCTe:chave)
            cte:setUpdateCte('cte_protocolo_autorizacao', apiCTe:numero_protocolo)
            cte:setUpdateCte('nuvemfiscal_uuid', apiCTe:nuvemfiscal_uuid)

            // Prepara os campos da tabela ctes_eventos para receber os updates
            if !Empty(apiCTe:motivo_status)
                cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, apiCTe:codigo_status, apiCTe:motivo_status)
            endif
            if !Empty(apiCTe:mensagem)
                cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_recebimento, apiCTe:codigo_mensagem, apiCTe:mensagem)
            endif

            empresa := appEmpresas:getEmpresa(cte:emp_id)

            // "2019-08-24T14:15:22Z"
            anoEmes := hb_ULeft(getNumbers(apiCTe:data_emissao), 6)
            directory := appData:dfePath + empresa:CNPJ + '\CTe\' + anoEmes + '\'

            if !hb_DirExists(directory)
                hb_DirBuild(directory)
            endif

            if apiCte:BaixarPDFdoDACTE()
                targetFile := apiCTe:chave + '-cte.pdf'
                if hb_MemoWrit(directory + targetFile, apiCTe:pdf_dacte)
                    saveLog("Arquivo PDF do DACTE salvo com sucesso: " + directory + targetFile)
                    // Aqui: Subir o arquivo para o servidor remoto
                    // uploadPDFdoDACTE(directory + targetFile)
                    cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, "PDF DACTE", "Arquivo PDF do DACTE salvo com sucesso")
                else
                    saveLog("Erro ao escrever pdf binary em arquivo " + targetFile + " na pasta " + directory)
                    cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, "PDF DACTE", "Falha ao salvar arquivo PDF do DACTE!")
                endif
            else
                saveLog("Arquivo PDF do DACTE não retornado; CTe Chave: " + apiCTe:chave)
                cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, "PDF DACTE", "Arquivo PDF do DACTE não foi retornado")
            endif

            if apiCte:BaixarXMLdoCTe()
                targetFile := apiCTe:chave + '-cte.xml'
                if hb_MemoWrit(directory + targetFile, apiCTe:xml_cte)
                    saveLog("Arquivo XML do CTe salvo com sucesso: " + directory + targetFile)
                    // Aqui: Subir o arquivo para o servidor web
                    // uploadXMLdoCTe(directory + targetFile)
                    cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, "XML CTE", "Arquivo XML do CTe salvo com sucesso")
                else
                    saveLog("Erro ao escrever xml binary em arquivo " + targetFile + " na pasta " + directory)
                    cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, "XML CTE", "Falha ao salvar arquivo XML do CTe!")
                endif
            else
                saveLog("Arquivo XML do CTe não retornado; CTe Chave: " + apiCTe:chave)
                cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, "XML CTE", "Arquivo XML do CTe não foi retornado")
            endif

        else
            aError := getMessageApiError(apiCTe, false)
            for each error in aError
                cte:setUpdateEventos("Erro", date_as_DateTime(date(), false, false), error["code"], error["message"])
            next
            cte:setSituacao("ERRO")
            // Debug
            consoleLog("apiCte:response" + apiCTe:response + hb_eol() + "API Conectado: " + iif(apiCTe:connected, "SIM", "NÃO"))
        endif
    else
        aError := getMessageApiError(apiCTe, false)
        for each error in aError
            cte:setUpdateEventos("Erro", date_as_DateTime(date(), false, false), error["code"], error["message"])
        next
        cte:setSituacao("ERRO")
    endif

    cte:setUpdateCte('cte_monitor_action', "EXECUTED")
    cte:save()
    cte:SaveEvento()

return

procedure cteGetFiles(cte)
return

procedure cteCancel()
return
