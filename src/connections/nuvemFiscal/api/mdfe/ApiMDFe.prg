#include "hmg.ch"
#include <hbclass.ch>

class TApiMDFe
    data mdfe readonly
    data emitente readonly
    data token
    data connection
    data connected readonly
    data body readonly
    data response readonly
    data httpStatus readonly
    data ContentType readonly
    data nuvemfiscal_uuid
    data referencia_uuid readonly
    data ambiente readonly
    data status readonly
    data chave_acesso readonly
    data created_at readonly
    data data_emissao readonly
    data data_evento readonly
    data data_recebimento readonly
    data codigo_status readonly
    data motivo_status readonly
    data numero_protocolo readonly
    data mensagem readonly
    data pdf_binary readonly
    data xml_binary readonly
    data tipo_evento readonly
    data digest_value readonly
    data baseUrl readonly
    data baseUrlID readonly

    method new(mdfe) constructor
    method Emitir()
    method Encerrar()
    method Cancelar()
    method Consultar()
    method BaixarPDFdoDAMDFE()
    method BaixarXMLdoMDFe()
    method defineBody()
    method ConsultarSVRS()
    method Sincronizar()
    method ListarMDFes()

end class

method new(mdfe) class TApiMDFe
    ::mdfe := mdfe
    ::emitente := mdfe:emitente
    ::connected := false
    ::response := ""
    ::httpStatus := 0
    ::ContentType := ""
    ::token := appNuvemFiscal:token
    ::nuvemfiscal_uuid := ::mdfe:nuvemfiscal_uuid
    ::referencia_uuid := mdfe:referencia_uuid
    ::status := ::mdfe:situacao
    ::data_emissao := ::mdfe:dhEmi
    ::chave_acesso := ::mdfe:chMDFe
    ::codigo_status := 0
    ::motivo_status := ""
    ::numero_protocolo := ::mdfe:nProt
    ::mensagem := ""
    ::tipo_evento := ""
    ::digest_value := ""

    if Empty(::token)
        saveLog("Token não defindo para conexão com a Nuvem Fiscal")
    else
        ::connection := GetMSXMLConnection()
        ::connected := !Empty(::connection)
    endif

    if (::mdfe:tpAmb == 1)
        // API de Produção
        ::ambiente := "producao"
        ::baseUrl := "https://api.nuvemfiscal.com.br/mdfe"
    else
        // API de Teste
        ::ambiente := "homologacao"
        ::baseUrl := "https://api.sandbox.nuvemfiscal.com.br/mdfe"
    endif

    if Empty(::nuvemfiscal_uuid)
        ::baseUrlID := ""
    else
        ::baseUrlID := ::baseUrl + "/" + ::nuvemfiscal_uuid
    endif

return self

method Emitir() class TApiMDFe
    local res, hRes, sefazOff, sefazStatus

    if !::connected
        return false
    endif

    // Request Body
    ::defineBody()

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "POST", ::baseUrl, ::token, "Emitir MDFe", ::body, "application/json")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']

        ::status := "erro"
        ::mensagem := res["response"]

        if (::ContentType == "json")
            hRes := hb_jsonDecode(::response)
            if hb_HGetRef(hRes, "error")
                hRes := hRes["error"]
                ::mensagem := hRes["message"]
                if ("o campo 'referencia' deve ser unico" $ desacentuar(Lower(::mensagem)))
                    if Empty(::nuvemfiscal_uuid)
                        res['error'] := ::ListarMDFes()
                    else
                        res['error'] := ::Consultar()
                    endif
                endif
            else
                saveLog({"Erro ao emitir MDFe na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
                    "Content-Type: ", res['ContentType'], hb_eol(), "Response: ", ::response})
            endif
        endif

        if !Empty(res["sefazOff"])

            sefazOff := res["sefazOff"]
            ::numero_protocolo := sefazOff["id"]
            ::codigo_status := sefazOff["codigo_status"]
            ::motivo_status := sefazOff["motivo_status"]
            sefazStatus := ::ConsultarSVRS()

            if !(sefazStatus["codigo_status"] == -1) .and. !(sefazStatus["codigo_status"] == 107)
                ::codigo_status := sefazStatus["codigo_status"]
                ::motivo_status := sefazStatus["motivo_status"]
                ::ambiente := sefazStatus["ambiente"]
                ::autorizador := sefazStatus["autorizador"]
                ::data_evento := sefazStatus["data_hora_consulta"]
                appData:mdfe_sefaz_offline := true
            endif

        endif

    else

        hRes := hb_jsonDecode(::response)
        ::nuvemfiscal_uuid := hRes['id']
        ::ambiente := hRes['ambiente']
        ::created_at := ConvertUTCdataStampToLocal(hRes['created_at'])
        ::status := hRes['status']
        ::data_emissao := ConvertUTCdataStampToLocal(hRes['data_emissao'])
        ::chave_acesso := hRes['chave']

        hAutorizacao := hRes['autorizacao']

        ::numero_protocolo := hb_HGetDef(hAutorizacao, 'numero_protocolo', hAutorizacao['id'])
        ::data_evento := ConvertUTCdataStampToLocal(hAutorizacao['data_evento'])
        ::data_recebimento := ConvertUTCdataStampToLocal(hAutorizacao['data_recebimento'])

        if hb_HGetRef(hAutorizacao, 'codigo_status')
            ::codigo_status := hAutorizacao['codigo_status']
            ::motivo_status := hAutorizacao['motivo_status']
        else
            if hb_HGetRef(hAutorizacao, 'codigo_mensagem')
                ::codigo_status := hAutorizacao['codigo_mensagem']
                ::motivo_status := hAutorizacao['mensagem']
            endif
        endif

        ::tipo_evento := hAutorizacao['tipo_evento']
        ::digest_value := hAutorizacao['digest_value']

    endif

return !res['error']

method Encerrar() class TApiMDFe
    local res, hRes, apiUrl := ::baseUrlID + "/encerramento"

    if !::connected
        return false
    endif

    ::body := '{"uf":"' + ::emitente:UF + '", "codigo_municipio":"' + ::emitente:cMunEnv + '"}'

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "POST", apiUrl, ::token, "Encerrar MDFe", ::body, "application/json")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao encerrar MDFe na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
            "Content-Type: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
        ::status := "erro"
        ::mensagem := res["response"]
    else
        hRes := hb_jsonDecode(::response)
        ::ambiente := hRes['ambiente']
        ::status := hRes['status']
        ::data_evento := ConvertUTCdataStampToLocal(hRes['data_evento'])
        ::data_recebimento := ConvertUTCdataStampToLocal(hRes['data_recebimento'])
        ::numero_protocolo := hb_HGetDef(hRes, 'numero_protocolo', hRes['id'])

        if hb_HGetRef(hRes, 'codigo_status')
            ::codigo_status := hRes['codigo_status']
            ::motivo_status := hRes['motivo_status']
        elseif hb_HGetRef(hRes, 'codigo_mensagem')
            ::codigo_status := hRes['codigo_mensagem']
            ::motivo_status := hRes['mensagem']
        else
            ::mensagem := res["response"]   // Mensagem bruta (string)
        endif
        if hb_HGetRef(hRes, 'tipo_evento')
            ::tipo_evento := hRes['tipo_evento']
        endif
    endif

return !res['error']

method Consultar() class TApiMDFe
    local res, hRes, hAutorizacao
    local apiUrl := ::baseUrl + "/nao-encerrados?cpf_cnpj=" + ::emitente:CNPJ

    if !::connected
        return false
    endif

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "GET", apiUrl, ::token, "Consultar MDFe")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao consultar MDFe na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
            "Content-Type: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
        ::status := "erro"
        ::mensagem := res["response"]
    else
        hRes := hb_jsonDecode(::response)
        ::nuvemfiscal_uuid := hRes['id']
        ::ambiente := hRes['ambiente']
        ::created_at := ConvertUTCdataStampToLocal(hRes['created_at'])
        ::status := hRes['status']
        ::data_emissao := ConvertUTCdataStampToLocal(hRes['data_emissao'])
        ::chave_acesso := hRes['chave']
        hAutorizacao := hRes['autorizacao']

        ::numero_protocolo := hb_HGetDef(hAutorizacao, 'numero_protocolo', hAutorizacao['id'])
        ::data_evento := ConvertUTCdataStampToLocal(hAutorizacao['data_evento'])
        ::data_recebimento := ConvertUTCdataStampToLocal(hAutorizacao['data_recebimento'])

        if hb_HGetRef(hAutorizacao, 'codigo_status')
            ::codigo_status := hAutorizacao['codigo_status']
            ::motivo_status := hAutorizacao['motivo_status']
        else
            if hb_HGetRef(hAutorizacao, 'codigo_mensagem')
                ::codigo_status := hAutorizacao['codigo_mensagem']
                ::motivo_status := hAutorizacao['mensagem']
            endif
        endif
    endif

return !res['error']

method Cancelar() class TApiMDFe
    local res, hRes, apiUrl := ::baseUrlID + "/cancelamento"

    if !::connected
        return false
    endif

    ::body := '{"justificativa":"Erro no preenchimento do Manifesto de Documentos Fiscais"}'

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "POST", apiUrl, ::token, "Cancelar MDFe", ::body, "application/json")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao cancelar MDFe na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
            "Content-Type: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
        ::status := "erro"
        ::mensagem := res["response"]
    else
        hRes := hb_jsonDecode(::response)
        ::ambiente := hRes['ambiente']
        ::status := hRes['status']
        ::data_evento := ConvertUTCdataStampToLocal(hRes['data_evento'])
        ::data_recebimento := ConvertUTCdataStampToLocal(hRes['data_recebimento'])
        ::numero_protocolo := hb_HGetDef(hRes, 'numero_protocolo', hRes['id'])

        if hb_HGetRef(hRes, 'codigo_status')
            ::codigo_status := hRes['codigo_status']
            ::motivo_status := hRes['motivo_status']
        elseif hb_HGetRef(hRes, 'codigo_mensagem')
            ::codigo_status := hRes['codigo_mensagem']
            ::motivo_status := hRes['mensagem']
        else
            ::mensagem := res["response"]
        endif
        if hb_HGetRef(hRes, 'tipo_evento')
            ::tipo_evento := res['tipo_evento']
        endif
    endif

return !res['error']

method BaixarPDFdoDAMDFE() class TApiMDFe
    local res, hRes, apiUrl := ::baseUrlID

    if !::connected
        return false
    endif

    switch Lower(::mdfe:situacao)
        case "autorizado"
            apiUrl += "/pdf"
            exit
        case "cancelado"
            apiUrl += "/cancelamento/pdf"
            exit
        case "encerrado"
            apiUrl += "/encerramento/pdf"
            exit
        case "erro"
            apiUrl += "/pdf"
            exit
    endswitch

    apiUrl += "?logotipo=true"
    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "GET", apiUrl, ::token, "Baixar PDF de DAMDFE " + ::mdfe:situacao, nil, nil, "*/*")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']   // Response Schema: "*/*", não retorna json, somente o binário

    if res['error']
        saveLog({"Erro ao baixar PDF do DAMDFE " + ::mdfe:situacao + " na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
            "Content-Type: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
        ::status := "erro"
        ::mensagem := res["response"]
    else
        ::pdf_binary := ::response
    endif

return !res['error']

method BaixarXMLdoMDFe() class TApiMDFe
    local res, hRes, apiUrl := ::baseUrlID

    if !::connected
        return false
    endif

    switch Lower(::mdfe:situacao)
        case "autorizado"
            apiUrl += "/xml"
            exit
        case "cancelado"
            apiUrl += "/cancelamento/xml"
            exit
        case "encerrado"
            apiUrl += "/encerramento/xml"
            exit
    endswitch

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "GET", apiUrl, ::token, "Baixar XML do MDFe " + ::mdfe:situacao, nil, nil, "*/*")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao baixar XML do MDFe " + ::mdfe:situacao + " na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
            "Content-Type: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
        ::status := "erro"
        ::mensagem := res["response"]
    else
        ::xml_binary := ::response
    endif

return !res['error']

method defineBody() class TApiMDFe
    loca ender
    local infMDFe, ide, emit, infModal, rodo, infANTT, veicTracao, infDoc, infResp, infSeg, seg
    local hBody, contratante, target, prodPred, ambiente

    // Tag ide
    ide := {=>}
    ide["cUF"] := ::emitente:cUF
    ide["tpAmb"] := ::mdfe:tpAmb
    ide["tpEmit"] := ::emitente:tpEmit

    /*
        TAG tpTransp
        Devido as validações da NT 2021/002 do MDFe que entraram em vigor 02/08/2021, alguns passaram a receber a rejeição
        "745 Rejeição: O tipo de transportador não ser informado quando não estiver informado proprietário do veículo de tração"
        Como todo agente de carga e transportadora usam veículo próprio, essa tag deve ser omitida para evitar o erro 745
   */
    // ide["tpTransp"] := null     // 1-ETC, 2-TAC, 3-CTC

    ide["mod"] := ::mdfe:mod
    ide["serie"] := ::mdfe:serie
    ide["nMDF"] := ::mdfe:nMDF
    // cMDF omitido, Nuvem fiscal gera automático
    // ide["cMDF"] := ::mdfe:cMDF
    ide["modal"] := ::mdfe:modal
    ide["dhEmi"] := ::mdfe:dhEmi
    ide["tpEmis"] := ::mdfe:tpEmis
    ide["procEmi"] := ::mdfe:procEmi
    ide["verProc"] := ::mdfe:verProc
    ide["UFIni"] := ::mdfe:UFIni
    ide["UFFim"] := ::mdfe:UFFim
    ide["infMunCarrega"] := ::mdfe:infMunCarrega

    if !Empty(::mdfe:infPercurso)
        ide["infPercurso"] := ::mdfe:infPercurso
    endif

    // Tag emit
    emit := {=>}
    emit["CNPJ"] := ::emitente:CNPJ

    if !Empty(::emitente:IE)
        emit["IE"] := ::emitente:IE
    endif

    emit["xNome"] := ::emitente:xNome

    if !Empty(::emitente:xFant)
        emit["xFant"] := ::emitente:xFant
    endif

    ender := {=>}
    ender["xLgr"] := ::emitente:xLgr
    ender["nro"] := ::emitente:nro
    if !Empty(::emitente:xCpl)
        ender["xCpl"] := ::emitente:xCpl
    endif
    ender["xBairro"] := ::emitente:xBairro
    ender["cMun"] := ::emitente:cMunEnv
    ender["xMun"] := ::emitente:xMunEnv
    ender["CEP"] := ::emitente:CEP
    ender["UF"] := ::emitente:UF
    ender["fone"] := ::emitente:fone

    emit["enderEmit"] := ender
    ender := nil

    infModal := {=>}
    // Versão do layout dos CTes anexos do modal rodo (CTe 4.00), porem a versão de Layout XML do MDFe é independente do CTe
    infModal["versaoModal"] := ::mdfe:versao

    if !Empty(::emitente:RNTRC)
        infANTT := {=>}
        infANTT["RNTRC"] := ::emitente:RNTRC
        // infANTT["infCIOT"] Não usado
        // infANTT["valePed"] Não usado

        if !Empty(::mdfe:infContratante)
            infANTT["infContratante"] := {}
            for each contratante in ::mdfe:infContratante
                if hb_HGetRef(contratante, "CNPJ")
                    AAdd(infANTT["infContratante"], {"xNome" => contratante["xNome"], "CNPJ" => contratante["CNPJ"]})
                elseif hb_HGetRef(contratante, "CPF")
                    AAdd(infANTT["infContratante"], {"xNome" => contratante["xNome"], "CPF" => contratante["CPF"]})
                endif
            next
        endif

    endif

    rodo := {=>}
    if !Empty(infANTT)
        rodo["infANTT"] := infANTT
    endif
    infANTT := nil

    // Veículo de Tração
    veicTracao := {=>}

    if !Empty(::mdfe:veicTracao["cInt"])
        veicTracao["cInt"] := ::mdfe:veicTracao["cInt"]
    endif

    veicTracao["placa"] := ::mdfe:veicTracao["placa"]

    if !Empty(::mdfe:veicTracao["RENAVAM"])
        veicTracao["RENAVAM"] := ::mdfe:veicTracao["RENAVAM"]
    endif

    veicTracao["tara"] := ::mdfe:veicTracao["tara"]

    if !Empty(::mdfe:veicTracao["capKG"])
        veicTracao["capKG"] := ::mdfe:veicTracao["capKG"]
    endif

    if !Empty(::mdfe:veicTracao["capM3"])
        veicTracao["capM3"] := ::mdfe:veicTracao["capM3"]
    endif

    // Proprietários do Veículo. Só preenchido quando o veículo não pertencer à empresa emitente do MDF-e
    if (::mdfe:veicTracao["tp_propriedade"] == "T")
        target := {=>}
        if !Empty(::mdfe:veicTracao["CNPJ"])
            target["CNPJ"] := ::mdfe:veicTracao["CNPJ"]
        elseif !Empty(::mdfe:veicTracao["CPF"])
            target["CPF"] := ::mdfe:veicTracao["CPF"]
        endif
        target["RNTRC"] := ::mdfe:veicTracao["RNTRC"]
        target["xNome"] := ::mdfe:veicTracao["xNome"]
        if !Empty(::mdfe:veicTracao["IE"])
            target["IE"] := ::mdfe:veicTracao["IE"]
        endif
        if !Empty(::mdfe:veicTracao["UF"])
            target["UF"] := ::mdfe:veicTracao["UF"]
        endif
        if Empty(::mdfe:veicTracao["tpProp"])
            target["tpProp"] := 0       // 0 - TAC Agregado
        else
            target["tpProp"] := ::mdfe:veicTracao["tpProp"]
        endif
    endif

    veicTracao["prop"] := target
    target := nil
    veicTracao["condutor"] := ::mdfe:condutor
    veicTracao["tpRod"] := PadL(::mdfe:veicTracao["tpRod"], 2, "0")
    veicTracao["tpCar"] := PadL(::mdfe:veicTracao["tpCar"], 2, "0")

    if !Empty(::mdfe:veicTracao["uf_licenciado"])
        veicTracao["UF"] := ::mdfe:veicTracao["uf_licenciado"]
    endif

    rodo["veicTracao"] := veicTracao
    veicTracao := nil

    // veicReboque: Veículo de Reboque - Não usado pelos meus clientes, opcional
    // LacRod: Numero do Lacre - Não usado pelos meus clientes, opcional

    infModal["rodo"] := rodo
    rodo := nil

    infMDFe := {=>}
    infMDFe["versao"] := ::mdfe:versao
    infMDFe["ide"] := ide
    infMDFe["emit"] := emit
    infMDFe["infModal"] := infModal
    infModal := nil

    // infMunDescarga
    infDoc := {=>}
    infDoc["infMunDescarga"] := ::mdfe:infDescarga

    infMDFe["infDoc"] := infDoc
    infDoc := nil

    infResp := {=>}
    infResp["respSeg"] := 1      // 1 - Emitente do MDF-e
    infResp["CNPJ"] := ::emitente:CNPJ

    infSeg := {=>}
    infSeg["xSeg"] := ::emitente:seguradora
    infSeg["CNPJ"] := ::emitente:CNPJ

    seg := {{"infResp" => infResp, "infSeg" => infSeg, "nApol" => ::emitente:apolice, "nAver" => ::mdfe:aVerb}}
    infMDFe["seg"] := seg
    infResp := infSeg := seg := nil

    // prodPred
    target := {=>}
    target["tpCarga"] := ::mdfe:prodPred["tpCarga"]
    target["xProd"] := ::mdfe:prodPred["xProd"]
    target["cEAN"] := ::mdfe:prodPred["cEAN"]
    target["NCM"] := ::mdfe:prodPred["NCM"]
    target["infLotacao"] := {"infLocalCarrega" => {"CEP" => ::emitente:CEP}, "infLocalDescarrega" => {"CEP" => ::mdfe:prodPred["infLocalDescarrega"]}}

    infMDFe["prodPred"] := target
    target := nil

    // tot
    target := {=>}
    target["qCTe"] := ::mdfe:qCTe
    target["vCarga"] := ::mdfe:vCarga
    target["cUnid"] := ::mdfe:cUnid
    target["qCarga"] := ::mdfe:qCarga

    infMDFe["tot"] := target
    target := nil

    // lacres: Não usado, opcional

    // autXML
    if !Empty(::mdfe:autXML)
        infMDFe["autXML"] := ::mdfe:autXML
    endif

    target := {=>}
    if !Empty(::mdfe:infAdFisco)
        target["infAdFisco"] := ::mdfe:infAdFisco
    endif
    if !Empty(::mdfe:infCpl)
        target["infCpl"] := ::mdfe:infCpl
    endif

    if !Empty(target)
        infMDFe["infAdic"] := target
    endif
    target := nil

    if !Empty(RegistryRead(appData:winRegistryPath + "Host\respTec\CNPJ"))
        infMDFe["infRespTec"] := { ;
            "CNPJ" => RegistryRead(appData:winRegistryPath + "Host\respTec\CNPJ"), ;
            "xContato" => RegistryRead(appData:winRegistryPath + "Host\respTec\xContato"), ;
            "email" => RegistryRead(appData:winRegistryPath + "Host\respTec\email"), ;
            "fone" => RegistryRead(appData:winRegistryPath + "Host\respTec\fone") ;
        }
    endif

    // Cria o Body Hash Table
    hBody := {"infMDFe" => infMDFe, "ambiente" => ::ambiente, "referencia" => ::referencia_uuid}
    ::body := hb_jsonEncode(hBody, 4)

return nil

method ConsultarSVRS() class TApiMDFe
    local res, hRes, apiUrl := ::baseUrl + "/sefaz/status?cpf_cnpj=" + ::emitente:CNPJ
    local sefaz := {"codigo_status" => -1}

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "GET", ::baseUrl, ::token, "MDFe: Consultar Status Sefaz", nil, nil, "*/*")

    if res["error"]
        saveLog({"MDFe: Erro ao consultar status SEFAZ, parece que SEFAZ/API-NUVEM FISCAL esta fora do ar", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
            "Content-Type: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
        ::status := "erro"
        ::mensagem := res["response"]
    else
        sefaz := hb_jsonDecode(res["response"])
    endif

return sefaz

method Sincronizar() class TApiMDFe
    local res, apiUrl := ::baseUrlID + "/sincronizar"

    if !::connected
        ::mdfe:setUpdateEventos(::numero_protocolo, date_as_DateTime(Date(), false, false), ::codigo_status, "Não é possível sincroinizar MDFe, API Nuvem Fiscal não conectado")
        saveLog("API Nuvem Fiscal não conectado")
        return false
    endif

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "POST", apiUrl, ::token, "Sincronizar MDFe a partir da SEFAZ", nil, nil, "*/*")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao sincronizar MDFe", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
            "Content-Type: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
        ::status := "erro"
        ::mensagem := res["response"]
    endif

return !res['error']

method ListarMDFes() class TApiMDFe
    local res, hRes, aRes := {}, mdfe, hAutorizacao
    local apiUrl := ::baseUrl + "?cpf_cnpj=" + ::emitente:CNPJ

    if !::connected
        return false
    endif

    apiUrl += chr(38) + "referencia=" + ::referencia_uuid
    apiUrl += chr(38) + "ambiente=" + ::ambiente

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "GET", apiUrl, ::token, "Listar MDFes por referencia_uuid")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao listar MDFes por referencia_uuid na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
            "Content-Type: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
        ::status := "erro"
        ::mensagem := res["response"]
    else
        hRes := hb_jsonDecode(::response)
        if hb_HGetRef(hRes, "data")
            aRes := hRes["data"]
        endif

        if Empty(aRes)
            ::codigo_status := 0
            ::motivo_status := "MDFe nao encontrado na Consulta por referencia_uuid"
            res["error"] := true
        else

            // Por referencia, só retorna um elemento no array
            mdfe := aRes[1]

            ::nuvemfiscal_uuid := mdfe['id']
            ::ambiente := mdfe['ambiente']
            ::created_at := ConvertUTCdataStampToLocal(mdfe['created_at'])
            ::status := mdfe['status']
            ::data_emissao := ConvertUTCdataStampToLocal(mdfe['data_emissao'])
            ::chave := mdfe['chave']

            hAutorizacao := mdfe['autorizacao']

            ::numero_protocolo := hb_HGetDef(hAutorizacao, 'numero_protocolo', hAutorizacao['id'])
            ::data_evento := ConvertUTCdataStampToLocal(hAutorizacao['data_evento'])
            ::data_recebimento := ConvertUTCdataStampToLocal(hAutorizacao['data_recebimento'])

            if hb_HGetRef(hAutorizacao, 'codigo_status')
                ::codigo_status := hAutorizacao['codigo_status']
                ::motivo_status := hAutorizacao['motivo_status']
            else
                if hb_HGetRef(hAutorizacao, 'codigo_mensagem')
                    ::codigo_status := hAutorizacao['codigo_mensagem']
                    ::motivo_status := hAutorizacao['mensagem']
                endif
            endif
            if hb_HGetRef(hAutorizacao, "digest_value")
                ::digest_value := hAutorizacao['digest_value']
            endif
            if (::status == "cancelado")
                ::codigo_status := 135
                ::motivo_status := "Evento registrado e vinculado ao CT-e"
            endif

            ::mdfe:setUpdateMDFe('cMDF', ::chave)
            ::mdfe:setUpdateMDFe('nuvemfiscal_uuid', ::nuvemfiscal_uuid)

        endif

    endif

    if !Empty(::nuvemfiscal_uuid) .and. !(::nuvemfiscal_uuid $ ::baseUrlID)
        ::baseUrlID := ::baseUrl + "/" + ::nuvemfiscal_uuid
    endif

return !res['error']