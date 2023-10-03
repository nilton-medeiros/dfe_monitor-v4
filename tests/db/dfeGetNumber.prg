/*
    Rotina de teste: getNumber(dfe)
    Obtem o próximo número do DFe em homologação
    para testes de emissão na nuvem fiscal
*/

function dfeGetNumber(dfeKey)
    local nextNumbers := hb_jsonDecode(hb_MemoRead(appData:systemPath + 'tests\db\' + "dfeNumbers.json"))
    local numeroDFe := hb_HGetDef(nextNumbers, dfeKey, 1)

    nextNumbers[dfeKey] := numeroDFe + 1

    hb_MemoWrit(appData:systemPath + "tests\db\dfeNumbers.json", hb_jsonEncode(nextNumbers, 4))

return numeroDFe
