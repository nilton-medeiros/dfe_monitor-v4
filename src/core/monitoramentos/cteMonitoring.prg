#include "hmg.ch"

procedure cteMonitoring()
    local cte, ctes := TDbConhecimentos():new()
    local emTeste := true // Debug: Remover esta linha após testes

    ctes:getListCTes()

    if (ctes:count == 0)
        return // Não retornou CTEs para transmitir a Sefaz
    endif

    for each cte in ctes:ctes
        // Debug: Em teste, remover esta variável "emTeste" e o "if emTeste" após testes
        if emTeste
            // Os CTes de 44501 à 44506 são dados reais e vem do banco de dados e serao processados no ambiente de homologação
            cteSubmit(cte)
            cteCancel(cte)
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
            cte:setUpdateCte('cte_monitor_action', "EXECUTED")
            cte:save()
            cte:saveEventos()
        endif
        DO EVENTS
    next

return
