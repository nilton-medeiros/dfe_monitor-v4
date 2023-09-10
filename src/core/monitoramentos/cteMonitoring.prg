#include <hmg.ch>

procedure cteMonitoring()
    local cte, ctes := TDbConhecimentos():new()
    local emTeste := true // Remover esta linha após testes

    if !ctes:ok
        return // Não retornou CTEs para transmitir a Sefaz
    endif
    for each cte in ctes:ctes
        // Teste: remover esta variável após testes
        if emTeste
            if cte:id < "44505"
                testSubmit(cte)
            elseif cte:id < "44509"
                testGetFiles(cte)
            else
                testCancel(cte)
            endif
        else
            switch cte:monitor_action
                case "SUBMIT"
                    testSubmit(cte)
                    exit
                case "GETFILES"
                    testGetFiles(cte)
                    exit
                case "CANCEL"
                    testCancel(cte)
                    exit
            endswitch
            DO EVENTS
        endif
    next

return