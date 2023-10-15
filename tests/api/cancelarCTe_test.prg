procedure testCancelarCTe()
    local cte, ctes := TDbCTes():new()

    ctes:getListCTes()
    cte := ctes:ctes[1]

    apiCTe := TApiCTe():new(cte)
    apiCTe:nuvemfiscal_uuid := "cte_3a0e4baa51d448c380fca25fc81cfdc6"
    apiCTe:chave := "35231057296543000115570010000000071000619173"

    if apiCTe:Cancelar()
        consoleLog({"CTe id: ", cte:id, ", nuvemfiscal_id: ", apiCTe:nuvemfiscal_uuid, " CANCELADO COM SUCESSO"})
    else
        consoleLog({"Erro ao cancelar CTe, nuvemfiscal_id: ", apiCTe:nuvemfiscal_uuid, ", mensagem: ", apiCTe:mensagem})
    endif

return