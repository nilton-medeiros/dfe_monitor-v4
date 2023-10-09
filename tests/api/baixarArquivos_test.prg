procedure testBaixarArquivos()
    local cte, ctes := TDbConhecimentos():new()
    local baixar

    ctes:getListCTes()
    cte := ctes:ctes[1]

    baixar := TApiCTe():new(cte)
    baixar:nuvemfiscal_uuid := "cte_3a0e2918fd064e3c85f7b0208df9779b"
    baixar:BaixarPDFdoDACTE()
    baixar:BaixarXMLdoCTe()

return