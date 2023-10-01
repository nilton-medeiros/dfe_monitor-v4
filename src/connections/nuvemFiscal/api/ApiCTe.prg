#include "hmg.ch"
#include <hbclass.ch>

class TApiCTe
    data token protected
    data connection protected
    data connected readonly
    data body readonly
    data response readonly
    data httpStatus readonly
    data ContentType readonly
    data nuvemfiscal_id readonly
    data status readonly
    data data_emissao readonly
    data chave readonly
    data codigo_status readonly
    data motivo_status readonly
    data numero_protocolo readonly
    data mensagem readonly
    data tipo_evento readonly

    method new() constructor
    method Emitir()
    // method Consultar()
    method defineBody(cte)

end class

method new() class TApiCTe

    ::connected := false
    ::response := ""
    ::httpStatus := 0
    ::ContentType := ""
    ::token := appNuvemFiscal:token
    ::nuvemfiscal_id := ""
    ::status := ""
    ::data_emissao := ""
    ::chave := ""
    ::codigo_status := ""
    ::motivo_status := ""
    ::numero_protocolo := ""
    ::mensagem := ""
    ::tipo_evento := ""

    if Empty(::token)
        saveLog("Token vazio para conexão com a Nuvem Fiscal")
    else
        ::connection := GetMSXMLConnection()
        ::connected := !Empty(::connection)
    endif

return self

method Emitir(cte) class TApiCTe
    local res, apiUrl, jsonRes

    if !::connected
        return false
    endif

    // Debug: Integração em teste, remover os comentários do laço if/endif abaixo
    // if cte:tpAmb == 1
        // API de Produção
        // apiUrl := "https://api.nuvemfiscal.com.br/cte"
    // else
        // API de Teste
        apiUrl := "https://api.sandbox.nuvemfiscal.com.br/cte"
    // endif

    // Request Body
    ::defineBody(cte)

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type
    res := Broadcast(::connection, "POST", apiUrl, ::token, "Emitir CTe", ::body)

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao emitir CTe na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
            "Content-Type: ", res['ContetType'], hb_eol(), "Response: ", res['response']})
        ::status := "erro"
    else
        jsonRes := hb_jsonDecode(::response)
        ::nuvemfiscal_id := jsonRes['id']
        ::status := jsonRes['status']
        ::data_emissao := jsonRes['data_emissao']
        ::chave := jsonRes['chave']
        ::codigo_status := jsonRes['autorizacao']['codigo_status']
        ::motivo_status := jsonRes['autorizacao']['motivo_status']
        ::numero_protocolo := jsonRes['autorizacao']['numero_protocolo']
        ::mensagem := jsonRes['autorizacao']['mensagem']
        ::tipo_evento := jsonRes['autorizacao']['tipo_evento']
    endif

return !res['error']

// Request Body
method defineBody(cte) class TApiCTe
    local hBody, infCte,ide, toma
    local compl, fluxo, entrega, ObsContFisco
    local emite, remet, exped, receb, desti, ender
    local vPrest, Comp, imp, ICMS
    local infCteNorm, infCarga, infDoc, docAnexos, infModal, rodo, aereo, tarifa
    local clieEMail, pos, obs, hComp, hDoc, tag, ambiente
    // Doc: https://dev.nuvemfiscal.com.br/docs/api#tag/Cte/operation/EmitirCte

    // Tag ide
    ide := {=>}
    ide["cUF"] := cte:cUF
    ide["cCT"] := cte:cCT
    ide["CFOP"] := cte:CFOP
    ide["natOp"] := cte:natOp
    ide["mod"] := cte:modelo
    ide["serie"] := cte:serie
    // ide["nCT"] := cte:nCT        |  Debug: Após testes, descomentar esta linha eremover a debaixo
    ide["nCT"] := dfeGetNumber("cte")
    ide["dhEmi"] := cte:dhEmi
    ide["tpImp"] :=  cte:tpEmp
    ide["tpEmis"] := cte:tpEmis
    ide["tpAmb"] := 2                       // Debug: 2- Homologação, mudar para -> cte:tpAmb quando terminar os testes
    ide["tpCTe"] := cte:tpCTe
    ide["procEmi"] := 0                     // 0 - Emissão de CT-e com aplicativo do contribuinte
    ide["verProc"] := Left(appData:version, hb_RAt('.', appData:version)) + '0'
    if (cte:indGlobalizado == 1)
        ide["indGlobalizado"] := 1
    endif
    ide["cMunEnv"] := cte:emitente:cMunEnv
    ide["xMunEnv"] := cte:emitente:xMunEnv
    ide["UFEnv"] := cte:emitente:UF
    ide["modal"] := cte:modal
    ide["tpServ"] := cte:tpServ
    ide["cMunIni"] := cte:cMunIni
    ide["xMunIni"] := cte:xMunIni
    ide["UFIni"] := cte:UFIni
    ide["cMunFim"] := cte:cMunFim
    ide["xMunFim"] := cte:xMunFim
    ide["UFFim"] := cte:UFFim
    ide["retira"] := cte:retira
    ide["xDetRetira"] := cte:xDetRetira
    ide["indIEToma"] := cte:indIEToma

    // Tag toma3 ou toma4
    if cte:tomador == 4
        toma := {=>}
        toma["toma"] := 4

        if Empty(cte:tom_cnpj)
            toma["CPF"] := cte:tom_cpf
        else
            toma["CNPJ"] := cte:tom_cnpj
        endif
        toma["IE"] := cte:tom_ie
        toma["xNome"] := cte:tom_xNome
        toma["xFant"] := cte:tom_xFant
        toma["fone"] := cte:tom_fone

        ender := {=>}
        ender["xLgr"] := cte:tom_end_logradouro
        ender["nro"] := cte:tom_end_numero
        ender["xCpl"] := cte:tom_end_complemento
        ender["xBairro"] := cte:tom_end_bairro
        ender["cMun"] := cte:tom_cid_codigo_municipio
        ender["xMun"] := cte:tom_cid_municipio
        ender["CEP"] := cte:tom_end_cep
        ender["UF"] := cte:tom_cid_uf
        ender["cPais"] := "1058"
        ender["xPais"] := "BRASIL"

        toma["enderToma"] := ender
        ender := nil

        toma["email"] := cte:tom_email

        ide["toma4"] := toma
        toma := nil

    else
        ide["toma3"] := {"toma" => cte:tomador}
    endif

    // tpEmis: 1 - Normal; 5 - Contingência FSDA; 7 - Autorização pela SVC-RS; 8 - Autorização pela SVC-SP
    if (hb_ntos(cte:tpEmis) $ '5|7|8')
        ide["dhCont"] := date_as_DateTime()
        ide["xJust"] := "Manutencao agendada na Sefaz"
    endif

    // Tag compl
    compl := {=>}
    compl["xCaracAd"] := cte:xCaracAd
    compl["xCaracSer"] := cte:xCaracSer
    compl["xEmi"] := cte:xEmi

    if (cte:modal == "02")
        // Tag fluxo para modal Aéreo
        fluxo := {=>}
        fluxo["xOrig"] := cte:xOrig
        fluxo["pass"] := {{"xPass" => cte:xPass}}
        fluxo["xDest"] := cte:xDest
        compl["fluxo"] := fluxo
        fluxo := nil
    endif

    // Tag Entrega: Tipo de data/período programado para a entrega: 0 - Sem data definida; 1 - Na data; 2 - Até a data; 3 - A partir da data; 4 – No período
    entrega := {=>}
    do case
    case (cte:tpPer == 0)
        entrega["semData"] := {"tpPer" => 0}
    case (hb_ntos(cte:tpPer) $ '1|2|3')
        entrega["comData"] := {"tpPer" => cte:tpPer, "dProg" => cte:dProg}
    case (cte:tpPer == 4)
        entrega["noPeriodo"] := {"tpPer" => cte:tpPer, "dIni" => cte:dIni, "dFim" => cte:dFim}
    endcase
    // Tipo de hora/período programado para a entrega: 0 - Sem hora definida; 1 - Na hora; 2 - Até a hora; 3 - A partir da hora; 4 – No intervalo de tempo
    do case
    case (cte:tpHor == 0)
        entrega["semHora"] := {"tpHor" => 0}
    case (hb_ntos(cte:tpHor) $ '1|2|3')
        entrega["comHora"] := {"tpHor" => cte:tpHor, "hProg" => cte:hProg}
    case (cte:tpHor == 4)
        entrega["noInter"] := {"tpHor" => cte:tpHor, "hIni" => cte:hIni, "hFim" => cte:hFim}
    endcase

    if !Empty(entrega)
        compl["Entrega"] := entrega
    endif
    entrega := nil

    compl["origCalc"] := cte:xMunIni
    compl["destCalc"] := cte:xMunFim

    if !Empty(cte:xObs)
        compl["xObs"] :=cte:xObs
    endif

    if !Empty(cte:obs_contr)
        ObsContFisco := {}
        for each obs in cte:obs_contr
            AAdd(ObsContFisco, {"xCampo" => obs["xCampo"], "xTexto" => obs["xTexto"]})
        next
        compl["ObsCont"] := ObsContFisco
        ObsContFisco := nil
    endif

    if !Empty(cte:obs_fisco)
        ObsContFisco := {}
        for each obs in cte:obs_fisco
            AAdd(ObsContFisco, {"xCampo" => obs["xCampo"], "xTexto" => obs["xTexto"]})
        next
        compl["ObsFisco"] := ObsContFisco
        ObsContFisco := nil
    endif

    // Tag emit
    emite := {=>}
    emite["CNPJ"] := cte:emitente:CNPJ
    emite["IE"] := cte:emitente:IE
    emite["xNome"] := cte:emitente:xNome
    emite["xFant"] := cte:emitente:xFant

    ender := {=>}
    ender["xLgr"] := cte:emitente:xLgr
    ender["nro"] := cte:emitente:nro
    ender["xCpl"] := cte:emitente:xCpl
    ender["xBairro"] := cte:emitente:xBairro
    ender["cMun"] := cte:emitente:cMunEnv
    ender["xMun"] := cte:emitente:xMunEnv
    ender["CEP"] := cte:emitente:CEP
    ender["UF"] := cte:emitente:UF
    ender["fone"] :=cte:emitente:fone

    emite["enderEmit"] := ender
    ender := nil

    /*
        NT 2022.001v.1.00 - A partir de 01/07/22 nova tag obrigatória CRT - Código do Regime Tributário
        1 - Simples Nacional;
        2 - Simples Nacional, excesso sublimite de receita bruta;
        3 - Regime Normal;
        4 - Simples Naciona - Microempreendedor Individual (MEI);
        AP = 1 e LW =3
        ** Versão 3.00: Deveria ter entrado em 01/07 mas não entrou, Sefaz não seguiu data prevista no manual!
        ** Versão 4.00: Testar se aceita ou retorna erro como na versão 3.00 do CTe
    */
    emite["CRT"] := cte:emitente:CRT

    // Tag rem
    remet := {=>}
    if Empty(cte:rem_cnpj)
        remet["CPF"] := cte:rem_cpf
    else
        remet["CNPJ"] := cte:rem_cnpj
        remet["IE"] := cte:rem_ie
    endif

    remet["xNome"] := cte:rem_razao_social
    remet["xFant"] := cte:rem_nome_fantasia
    remet["fone"] :=cte:rem_fone

    ender := {=>}
    ender["xLgr"] := cte:rem_end_logradouro
    ender["nro"] := cte:rem_end_numero
    ender["xCpl"] := cte:rem_end_complemento
    ender["xBairro"] := cte:rem_end_bairro
    ender["cMun"] := cte:rem_cid_codigo_municipio
    ender["xMun"] := cte:rem_cid_municipio
    ender["CEP"] := cte:rem_end_cep
    ender["UF"] := cte:rem_cid_uf

    remet["enderReme"] := ender
    ender := nil

    if !Empty(cte:rem_email)
        remet["email"] := cte:rem_email
    endif

    // Tag exped
    exped := {=>}
    if Empty(cte:exp_cnpj)
        exped["CPF"] := cte:exp_cpf
    else
        exped["CNPJ"] := cte:exp_cnpj
        exped["IE"] := cte:exp_ie
    endif

    exped["xNome"] := cte:exp_razao_social
    exped["fone"] :=cte:exp_fone

    ender := {=>}
    ender["xLgr"] := cte:exp_end_logradouro
    ender["nro"] := cte:exp_end_numero
    ender["xCpl"] := cte:exp_end_complemento
    ender["xBairro"] := cte:exp_end_bairro
    ender["cMun"] := cte:exp_cid_codigo_municipio
    ender["xMun"] := cte:exp_cid_municipio
    ender["CEP"] := cte:exp_end_cep
    ender["UF"] := cte:exp_cid_uf

    exped["enderExped"] := ender
    ender := nil

    if !Empty(cte:exp_email)
        exped["email"] := cte:exp_email
    endif

    // Tag receb
    receb := {=>}
    if Empty(cte:rec_cnpj)
        receb["CPF"] := cte:rec_cpf
    else
        receb["CNPJ"] := cte:rec_cnpj
        receb["IE"] := cte:rec_ie
    endif

    receb["xNome"] := cte:rec_razao_social
    receb["fone"] :=cte:rec_fone

    ender := {=>}
    ender["xLgr"] := cte:rec_end_logradouro
    ender["nro"] := cte:rec_end_numero
    ender["xCpl"] := cte:rec_end_complemento
    ender["xBairro"] := cte:rec_end_bairro
    ender["cMun"] := cte:rec_cid_codigo_municipio
    ender["xMun"] := cte:rec_cid_municipio
    ender["CEP"] := cte:rec_end_cep
    ender["UF"] := cte:rec_cid_uf

    receb["enderExped"] := ender
    ender := nil

    if !Empty(cte:rec_email)
        receb["email"] := cte:rec_email
    endif

    // Tag dest
    desti := {=>}
    if Empty(cte:des_cnpj)
        desti["CPF"] := cte:des_cpf
    else
        desti["CNPJ"] := cte:des_cnpj
        desti["IE"] := cte:des_ie
    endif

    desti["xNome"] := cte:des_razao_social
    desti["fone"] :=cte:des_fone

    if !Empty(cte:des_ISUF)
        desti["ISUF"] := cte:des_ISUF
    endif

    ender := {=>}
    ender["xLgr"] := cte:des_end_logradouro
    ender["nro"] := cte:des_end_numero
    ender["xCpl"] := cte:des_end_complemento
    ender["xBairro"] := cte:des_end_bairro
    ender["cMun"] := cte:des_cid_codigo_municipio
    ender["xMun"] := cte:des_cid_municipio
    ender["CEP"] := cte:des_end_cep
    ender["UF"] := cte:des_cid_uf

    desti["enderExped"] := ender
    ender := nil

    if !Empty(cte:des_email)
        desti["email"] := cte:des_email
    endif

    // infCte -------------------------
    infCte["versao"] := "4.00"                     // Debug: mudar para -> //cte:versao_xml quando terminar os testes
    infCte["ide"] := ide
    infCte["compl"] := compl
    infCte["emit"] := emite
    infCte["rem"] := remet
    infCte["exped"] := exped
    infCte["receb"] := receb
    infCte["dest"] := desti

    // Libera as variáveis e deixa o Garbage Collector do Harbour limpar a memória
    ide := compl := emite := remet := exped := receb := desti := nil

    vPrest := {=>}
    vPrest["vTprest"] := cte:vTPrest
    vPrest["vRec"] := cte:vTPrest

    if !Empty(cte:comp_calc)
        Comp := {}
        for each hComp in cte:comp_calc
            AAdd(Comp, {"xNome" => hComp["xNome"], "vComp" => hComp["vComp"]})
        next
        vPrest["Comp"] := Comp
        Comp := nil
    endif

    infCte["vPrest"] := vPrest
    vPrest := nil

    ICMS := {=>}

    switch cte:codigo_sit_tributaria
        case "00 - Tributação normal do ICMS"
            ICMS["ICMS00"] := {"CST" => "00", "vBC" => cte:vBC, "pICMS" => cte:pICMS, "vICMS" => cte:vICMS}
            exit
        case "20 - Tributação com redução de BC do ICMS"
            ICMS["ICMS20"] := {"CST" => "20", "pRedBC" => cte:pRedBC, "vBC" => cte:vBC, "pICMS" => cte:pICMS, "vICMS" => cte:vICMS}
            exit
        case "60 - ICMS cobrado anteriormente por substituição tributária"
            ICMS["ICMS60"] := {"CST" => "60", "vBCSTRet" => cte:vBC, "vICMSSTRet" => cte:vICMS, "pICMSSTRet" => cte:pICMS, "vCred" => cte:vCred}
            exit
        case "90 - ICMS outros"
            ICMS["ICMS90"] := {"CST" => "90", "pRedBC" => cte:pRedBC, "vBC" => cte:vBC, "pICMS" => cte:pICMS, "vICMS" => cte:vICMS, "vCred" => cte:vCred}
                exit
        case "90 - ICMS devido à UF de origem da prestação, quando diferente da UF emitente"
            ICMS["ICMSOutraUF"] := {"CST" => "90", "pRedBCOutraUF" => cte:pRedBC, "vBCOutraUF" => cte:vBC, "pICMSOutraUF" => cte:pICMS, "vICMSOutraUF" => cte:vICMS}
            exit
        case "SIMPLES NACIONAL"
            ICMS["ICMSSN"] := {"CST" => "90", "indSN" => 1}
            exit
        otherwise
            if (hb_ULeft(cte:codigo_sit_tributaria, 2) $ "40|41|51")
                // 45 - ICMS Isento, não Tributado ou diferido
                ICMS["ICMS45"] := {"CST" => hb_ULeft(cte:codigo_sit_tributaria, 2)}
            endif
    endswitch

    imp := {=>}
    imp["ICMS"] := ICMS
    imp["vTotTrib"] := cte:vTotTrib

    if !Empty(cte:infAdFisco)
        imp["infAdFisco"] := cte:infAdFisco
    endif
    if !Empty(cte:calc_difal)
        imp["ICMSUFFim"] := {"vBCUFFim" => cte:vTPrest, ;
                                 "pFCPUFFim" => cte:calc_difal["pFCPUFFim"], ;
                                 "pICMSUFFim" => cte:calc_difal["pICMSUFFim"], ;
                                 "pICMSInter" => cte:calc_difal["pICMSInter"], ;
                                 "vFCPUFFim" => cte:calc_difal["vFCPUFFim"], ;
                                 "vICMSUFFim" => cte:calc_difal["vICMSUFFim"], ;
                                 "vICMSUFIni" => cte:calc_difal["vICMSUFIni"]}
     endif

    infCte["imp"] := imp
    imp := ICMS := nil

    if (hb_ntos(cte:tpCTe) $ "03")
        // 0 - CT-e Normal e 3 - CT-e de Substituição

        infCarga := {=>}
        infCarga["vCarga"] := cte:vCarga
        infCarga["proPred"] := cte:proPred
        infCarga["xOutCat"] := cte:xOutCat
        infCarga["infQ"] := {{"cUnid" => "01", "tpMed" => "PESO BRUTO", "qCarga" => number_format(cte:peso_bruto, 4)}, ;
                             {"cUnid" => "01", "tpMed" => "PESO BC", "qCarga" => number_format(cte:peso_bc, 4)}, ;
                                {"cUnid" => "01", "PESO CUBADO" => "PESO BC", "qCarga" => number_format(cte:peso_cubado, 4)}, ;
                                    {"cUnid" => "00", "PESO CUBAGEM" => "PESO BC", "qCarga" => number_format(cte:cubagem_m3, 4)}, ;
                             {"cUnid" => "03", "VOLS." => "PESO BC", "qCarga" => number_format(cte:qtde_volumes, 4)} ;
                            }

        // vCargaAverb // Não utilizado ou desnecessário

        infCteNorm := {=>}
        infCteNorm["infCarga"] := infCarga
        infCarga := nil

        infDoc := {=>}
        docAnexos := {}

        switch cte:tipo_doc_anexo
            case 1 // 1-Nota Fiscal
                tag := "infNF"
                for each hDoc in cte:doc_anexo
                    AAdd(docAnexos, {"mod" => PadL(hDoc["modelo"], 2, "0"), ;
                                     "serie" => PadL(hDoc["serie"], 3, "0"), ;
                                     "nDoc" => hDoc["nDoc"], ;
                                     "dEmi" => hDoc["dEmi"], ;
                                     "vBC" => hDoc["vBC"], ;
                                     "vICMS" => hDoc["vICMS"], ;
                                     "vBCST" => hDoc["vBCST"], ;
                                     "vST" => hDoc["vST"], ;
                                     "vProd" => hDoc["vProd"], ;
                                     "vNF" => hDoc["vNF"], ;
                                     "nCFOP" => hDoc["nCFOP"], ;
                                     "nPeso" => hDoc["nPeso"], ;
                                     "PIN" => hDoc["PIN"], ;
                                     "dPrev" => hDoc["dPrev"] ;
                                })
                next
                exit
            case 2 // 2-NFe
                tag := "infNFe"
                for each hDoc in cte:doc_anexo
                    if Empty(hDoc["PIN"])
                        AAdd(docAnexos, {"chave" => hDoc["chave"]})
                    else
                        AAdd(docAnexos, {"chave" => hDoc["chave"], "PIN" => hDoc["PIN"]})
                    endif
                next
                exit
            case 3 // 3-Declarações, outros
                tag := "infOutros"
                for each hDoc in cte:doc_anexo
                    AAdd(docAnexos, {"tpDoc" => hDoc["tpDoc"], ;
                                        "descOutros" => hDoc["descOutros"], ;
                                        "nDoc" => hDoc["nDoc"], ;
                                        "dEmi" => hDoc["dEmi"], ;
                                        "vDocFisc" => hDoc["vDocFisc"] ;
                                    })
                next
                exit
        endswitch
        // infUnidCarga  -- Opcional. Informação indisponível na emissão do CTe
        // infUnidTransp -- Opcional. Informação indisponível na emissão do CTe

        infDoc[tag] := docAnexos
        infCteNorm["infDoc"] := infDoc
        infDoc := docAnexos := nil

        if !Empty(cte:docAnt)
            infCteNorm["docAnt"] := cte:docAnt
        endif

        infModal := {=>}
        infModal["versaoModal"] := "4.00"   // Debug: mudar para -> //cte:versao_xml quando terminar os testes

        if (cte:tpCTe == 0)
            // tpCTe: 0 - Normal
            if (cte:tpServ == 0)
                // tpServ: 0 - Normal
                if (cte:modal == "01")
                    // Rodo: Informação do modal rodoviário

                    rodo := {=>}
                    rodo["RNTRC"] := cte:emitente:RNTRC

                    if !Empty(cte:rodoOcc)
                        // Ordens de Coletas
                        rodo["occ"] := {}
                        for each occ in cte:rodoOcc
                            if Empty(occ["serie"])
                                AAdd(rodo["occ"], ;
                                    {"nOcc" => occ["nOcc"], ;
                                     "dEmi" => occ["dEmi"], ;
                                     "emiOcc" => {"CNPJ" => occ["CNPJ"], "IE" => occ["IE"], "UF" => occ["UF"]} ;
                                    })
                            else
                                AAdd(rodo["occ"], ;
                                    {"serie" => occ["serie"], ;
                                     "nOcc" => occ["nOcc"], ;
                                     "dEmi" => occ["dEmi"], ;
                                     "emiOcc" => {"CNPJ" => occ["CNPJ"], "IE" => occ["IE"], "UF" => occ["UF"]} ;
                                    })
                            endif
                        next
                    endif
                    infModal["rodo"] := rodo
                    infCteNorm["infModal"] := infModal
                    infModal := rodo := nil

                else
                    // Aéreo: Informação do modal Aéreo
                    aereo := {=>}
                    aereo["nMinu"] := cte:cCT
                    aereo["nOCA"] := cte:nOCA
                    aereo["dPrevAereo"] := cte:dPrevAereo
                    aereo["natCarga"] := cte:aereo


                    sql:add("ccc_titulo AS xNome, ")
                    sql:add("ccc_valor AS vComp, ")
                    sql:add("ccc_tipo_tarifa AS CL, ")
                    sql:add("ccc_valor_tarifa_kg AS vTar ")
                    sql:add("FROM ctes_comp_calculo ")

                    tarifa := cte:comp_calc[1]
                    aereo["tarifa"] := {"CL" => tarifa["CL"], ;
                                        "cTar" => cte:cTar, ;
                                        "vTar" => tarifa["vTar"] ;
                                        }
                    infModal["aereo"] := aereo
                endif

                infCteNorm["infModal"] := infModal
                infModal := rodo := aereo := nil

                // veicNovos, cobr, infCteSub: Não utilizados
                if (cte:indGlobalizado == 1)
                    infCteNorm["infGlobalizado"] := {"xObs" => "Procedimento efetuado conforme Resolução/SEFAZ n. 2.833/2017"}
                endif
            else
                // tpServ: 1 - Subcontratação; 2 – Redespacho; 3 – Redespacho Intermediário; 4 – Serviço Vinculado à Multimodal
                // infServVinc: Não utilizado
            endif
        endif
        infCte["infCTeNorm"] := infCteNorm
        infCteNorm := nil
    elseif (cte:tpCTe == 1)
        // tpCTe: 1 - CT-e de Complemento de Valores
        // infCteComp: Não implementado
    else
      // 2 - CT-e de Anulação * Não implementado
      // infCteAnu | Detalhamento do CT-e do tipo Anulação
    endif

    autXML := {}

    if !Empty(cte:tom_email) .and. (cte:tomador == 4)
        if Empty(cte:tom_cnpj)
            AAdd(autXML, {"CPF" => cte:tom_cpf})
        else
            AAdd(autXML, {"CNPJ" => cte:tom_cnpj})
        endif
    endif
    if !Empty(cte:rem_email)
        if Empty(cte:rem_cnpj)
            AAdd(autXML, {"CPF" => cte:rem_cpf})
        else
            AAdd(autXML, {"CNPJ" => cte:rem_cnpj})
        endif
    endif
    if !Empty(cte:des_email)
        if Empty(cte:des_cnpj)
            AAdd(autXML, {"CPF" => cte:des_cpf})
        else
            AAdd(autXML, {"CNPJ" => cte:des_cnpj})
        endif
    endif
    if !Empty(cte:exp_email)
        if Empty(cte:exp_cnpj)
            AAdd(autXML, {"CPF" => cte:exp_cpf})
        else
            AAdd(autXML, {"CNPJ" => cte:exp_cnpj})
        endif
    endif
    if !Empty(cte:rec_email)
        if Empty(cte:rec_cnpj)
            AAdd(autXML, {"CPF" => cte:rec_cpf})
        else
            AAdd(autXML, {"CNPJ" => cte:rec_cnpj})
        endif
    endif

    if !Empty(autXML)
        infCte["autXML"] := autXML
    endif
    autXML := nil

    if !Empty(RegistryRead(appData:winRegistryPath + "Host\respTec\CNPJ"))
        infCte["respTec"] := {"CNPJ" => RegistryRead(::winRegistryPath + "Host\respTec\CNPJ"), ;
                              "xContato" => RegistryRead(::winRegistryPath + "Host\respTec\xContato"), ;
                              "email" => RegistryRead(::winRegistryPath + "Host\respTec\email"), ;
                              "fone" => RegistryRead(::winRegistryPath + "Host\respTec\fone")}
    endif

    // infSolicNFF: Não utilizado
    // infCteSupl: Gerado automaticamente pela nuvem fiscal

    ambiente := "homologacao"   // Debug: Após encerrar os testes, alterar esta linha

    // Cria o Body Hasht Table
    hBody := {"infCte" => infCte, "ambiente" => ambiente, "referencia" => cte:referencia_uuid}
    ::body := hb_jsonEncode(hBody, 4)

    hb_MemoWrit(appData:systemPath + "tmp\CTe" + hb_ntos(cte:referencia_uuid) + ".json", ::body)

return nil