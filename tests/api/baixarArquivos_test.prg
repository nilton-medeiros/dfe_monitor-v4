procedure testBaixarArquivos()
    local cte, ctes := TDbConhecimentos():new()
    local baixar

    ctes:getListCTes()
    cte := ctes:ctes[1]

    baixar := TApiCTe():new(cte)
    baixar:nuvemfiscal_uuid := "cte_3a0e28a9b51c423080296501104993b"
    baixar:BaixarPDFdoDACTE()
    baixar:BaixarXMLdoCTe()

return