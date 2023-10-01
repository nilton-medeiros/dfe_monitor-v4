#include "hmg.ch"

procedure cteMonitoring()
    local cte, ctes := TDbConhecimentos():new()
    local emTeste := true // Remover esta linha após testes

    if !ctes:ok
        return // Não retornou CTEs para transmitir a Sefaz
    endif

    for each cte in ctes:ctes
        // Testes: remover esta variável "emTeste" e o "if emTeste" após testes
        if emTeste
            // Os CTes de 44501 à 44506 são dados reais e vem do banco de dados e serao processados no ambiente de homologação
            if cte:id < 44503
                cteSubmit(cte)
            elseif cte:id < 44505
                cteGetFiles(cte)
            else
                cteCancel(cte)
            endif
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
    local apiCTe := TApiCTe():new()
    local startTimer, consultouCTe, empresa
    local targetFile, anoEmes, directory

    if apiCTe:Emitir(cte)

        if apiCTe:status == 'pendente'
            sysWait(2)  // Aguarda 2 segundos para obter autorizado ou erro
            consultouCTe := apiCTe:Consultar()
            startTimer := Seconds()

            do while consultouCTe .and. (apiCTe:status == 'pendente') .and. (Seconds() - startTimer < 10)
                // Situação pouco provável, porem não impossível: Insiste obter informações por até 10 segundos
                sysWait(2)
                consultouCTe := apiCTe:Consultar()
            enddo
        endif

        cte:setSituacao(apiCTe:status)

        if consultouCTe

            // Prepara os campos da tabela ctes para receber os updates
            cte:setUpdateCte('cte_chave', apiCTe:chave)
            cte:setUpdateCte('cte_monitor_action', "EXECUTED")
            cte:setUpdateCte('cte_protocolo_autorizacao', apiCTe:numero_protocolo)
            cte:setUpdateCte('nuvemfiscal_uuid', apiCTe:nuvemfiscal_uuid)
            cte:Save()
            // Prepara os campos da tabela ctes_eventos para receber os updates
            cte:setUpdateEventos('cte_ev_protocolo', apiCTe:numero_protocolo)
            cte:setUpdateEventos('cte_ev_data_hora', apiCTe:data_evento)
            cte:setUpdateEventos('cte_ev_evento', apiCTe:codigo)
            cte:setUpdateEventos('cte_ev_detalhe', apiCTe:mensagem)
            cte:SaveEvento()

            empresa := appEmpresas:getEmpresa(cte:emp_id)
            // "2019-08-24T14:15:22Z"
            anoEmes := hb_ULeft(getNumbers(apiCTe:data_emissao), 6)
            directory := appData:dfePath + empresa:CNPJ + '\CTe\' + anoEmes + '\'

            if !hb_DirExists(directory)
                hb_DirBuild(directory)
            endif

            if Empty(apiCte:pdf_dacte)
                cte:setUpdateEventos('cte_ev_protocolo', apiCTe:numero_protocolo)
                cte:setUpdateEventos('cte_ev_data_hora', apiCTe:data_evento)
                cte:setUpdateEventos('cte_ev_detalhe', "Arquivo PDF do DACTE não foi retornado")
                cte:SaveEvento()
                saveLog("Arquivo PDF do DACTE não retornado; CTe Chave: " + apiCTe:chave)
            else
                targetFile := apiCTe:chave + '-cte.pdf'
                if hb_MemoWrit(directory + targetFile, apiCTe:pdf_dacte)
                    saveLog("Arquivo PDF da DACTE salvo com sucesso: " + directory + targetFile)
                    // Aqui: Subir o arquivo para o servidor remoto
                else
                    saveLog("Erro ao escrever pdf binary em arquivo " + targetFile + " na pasta " + directory)
                endif
            endif

            // apiCte:xml_cte

        else
        endif
    else
    endif

return
procedure cteGetFiles()
return
procedure cteCancel()
return