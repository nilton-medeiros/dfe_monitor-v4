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
            if cte:id < "44503"
                testSubmit(cte)
            elseif cte:id < "44504"
                testGetFiles(cte)
            else
                testCancel(cte)
            endif
            if !MsgOkCancel({'testSubmit: OK', hb_eol(), 'testGetFiles: OK', hb_eol(),'testCancel: OK', hb_eol(), "Ver log do sistema."}, "Testes Concluídos")
                turnOFF(true)
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