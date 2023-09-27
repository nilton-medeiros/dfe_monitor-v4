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
    method Consultar()
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
    // if empresa:tpAmb == "1"
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
        jsonRes := jsonDecode(::response)
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
    local clieEMail, pos, obs, comp
    // Doc: https://dev.nuvemfiscal.com.br/docs/api#tag/Cte/operation/EmitirCte

    ::body := '{' + hb_eol()
    ::body += '    "infCte": {' + hb_eol()
    ::body += '        "versao": "' + cte:versao_xml + '",' + hb_eol()
    ::body += '        "ide": {' + hb_eol()
    ::body += '            "cUF": ' + cte:emitente:cUF + ',' + hb_eol()
    ::body += '            "cCT": "' + cte:cCT + '",' + hb_eol()    // Minuta
    ::body += '            "CFOP": "' + cte:CFOP + '",' + hb_eol()
    ::body += '            "natOp": "' + cte:natOp + '",' + hb_eol()
    ::body += '            "mod": ' + cte:modelo + ',' + hb_eol()
    ::body += '            "serie": ' + cte:serie + ',' + hb_eol()
    ::body += '            "nCT": ' + cte:nCT + ',' + hb_eol()
    ::body += '            "dhEmi": "' + cte:dhEmi + '",' + hb_eol()
    ::body += '            "tpImp": ' + cte:emitente:tpImp + ',' + hb_eol()
    ::body += '            "tpEmis": ' + cte:tpEmis + ',' + hb_eol()
    // ::body += '            "cDV": 0,' + hb_eol() // Será gerado pela api da nuvem fiscal
    // Debug: Modo 2 - Homologação, remover a linha baixo quando compilar versão final modo produção
    ::body += '            "tpAmb": 2,' + hb_eol()
    // Debug: Descomentar linha abaixo em modo produção
    // ::body += '            "tpAmb": ' + cte:emitente:tpAmb + ',' + hb_eol()
    ::body += '            "tpCTe": ' + cte:tpCTe + ',' + hb_eol()
    ::body += '            "procEmi": 0,' + hb_eol()    // 0 - Emissão de CT-e com aplicativo do contribuinte
    ::body += '            "verProc": "' + Left(appData:version, hb_RAt('.', appData:version)) + '0",' + hb_eol()

    // Consultar regra em CTeMonitor-v1\cte_createObject.prg procedure infGlobalizado(930)
    if (cte:indGlobalizado == '1')
        ::body += '            "indGlobalizado": 1,' + hb_eol()
    endif

    ::body += '            "cMunEnv": "' + cte:emitente:cMunEnv + '",' + hb_eol()
    ::body += '            "xMunEnv": "' + cte:emitente:xMunEnv + '",' + hb_eol()
    ::body += '            "UFEnv": "' + cte:emitente:UF + '",' + hb_eol()
    ::body += '            "modal": "' + cte:modal + '",' + hb_eol()
    ::body += '            "tpServ": ' + cte:tpServ + ',' + hb_eol()
    ::body += '            "cMunIni": "' + cte:cMunIni + '",' + hb_eol()
    ::body += '            "xMunIni": "' + cte:xMunIni + '",' + hb_eol()
    ::body += '            "UFIni": "' + cte:UFIni + '",' + hb_eol()
    ::body += '            "cMunFim": "' + cte:cMunFim + '",' + hb_eol()
    ::body += '            "xMunFim": "' + cte:xMunFim + '",' + hb_eol()
    ::body += '            "UFFim": "' + cte:UFFim + '",' + hb_eol()
    ::body += '            "retira": ' + cte:retira + ',' + hb_eol()
    ::body += '            "xDetRetira": "' + cte:xDetRetira + '",' + hb_eol()
    ::body += '            "indIEToma": ' + cte:indIEToma + ',' + hb_eol()

    // Consultar regra em CTeMonitor-v1\cte_createObject.prg procedure ideCTe(241)
    if cte:tomador == '4'
        ::body += '            "toma4": {' + hb_eol()
        ::body += '                "toma": 4,' + hb_eol()

        if Empty(cte:tom_cnpj)
            ::body += '                "CPF": "' + cte:tom_cpf + '",' + hb_eol()
        else
            ::body += '                "CNPJ": "' + cte:tom_cnpj + '",' + hb_eol()
        endif
        ::body += '                "IE": "' + cte:tom_ie + '",' + hb_eol()
        ::body += '                "xNome": "' + cte:tom_xNome + '",' + hb_eol()
        ::body += '                "xFant": "' + cte:tom_xFant + '",' + hb_eol()
        ::body += '                "fone": "' + cte:tom_fone + '",' + hb_eol()
        ::body += '                "enderToma": {' + hb_eol()
        ::body += '                    "xLgr": "' + cte:tom_end_logradouro + '",' + hb_eol()
        ::body += '                    "nro": "' + cte:tom_end_numero + '",' + hb_eol()
        ::body += '                    "xCpl": "' + cte:tom_end_complemento + '",' + hb_eol()
        ::body += '                    "xBairro": "' + cte:tom_end_bairro + '",' + hb_eol()
        ::body += '                    "cMun": "' + cte:tom_cid_codigo_municipio + '",' + hb_eol()
        ::body += '                    "xMun": "' + cte:tom_cid_municipio + '",' + hb_eol()
        ::body += '                    "CEP": "' + cte:tom_end_cep + '",' + hb_eol()
        ::body += '                    "UF": "' + cte:tom_cid_uf + '",' + hb_eol()
        ::body += '                    "cPais": "1058",' + hb_eol()
        ::body += '                    "xPais": "BRASIL"' + hb_eol()
        ::body += '                },' + hb_eol()

        pos := hb_AScan(cte:clie_emails, {|hClie| hClie['name'] == 'tomador'})
        clieEMail := cte:clie_emails[pos]['email']

        ::body += '                "email": "' + clieEMail + '"' + hb_eol()
        ::body += '            },' + hb_eol()
    else
        ::body += '            "toma3": {' + hb_eol()
        ::body += '                "toma": ' + cte:tomador + ' + hb_eol()
        ::body += '            },' + hb_eol()
    endif

    if (:tpEmis:value $ '5|7|8')
        ::body += '            "dhCont": "' + date_as_DateTime() + '",' + hb_eol()
        ::body += '            "xJust": "Manutencao agendada na Sefaz"' + hb_eol()
     endif

    // Fecha ide
    ::body += '        },' + hb_eol()
    ::body += '        "compl": {' + hb_eol()
    ::body += '            "xCaracAd": "' + cte:xCaracAd + '",' + hb_eol()
    ::body += '            "xCaracSer": "' + cte:xCaracSer + '",' + hb_eol()
    ::body += '            "xEmi": "' + cte:xEmi + '",' + hb_eol()

    if (::modal == '02')
        // Aereo
        ::body += '            "fluxo": {' + hb_eol()
        ::body += '                "xOrig": "' + cte:xOrig + '",' + hb_eol()
        ::body += '                "pass": [' + hb_eol()
        ::body += '                    {' + hb_eol()
        ::body += '                        "xPass": "' + cte:xPass + '"' + hb_eol()
        ::body += '                    }' + hb_eol()
        ::body += '                ],' + hb_eol()
        ::body += '                "xDest": "' + cte:xDest + '"' + hb_eol()
        // ::body += '                "xRota": null' + hb_eol()
        ::body += '            },' + hb_eol()
    endif

    ::body += '            "entrega": {' + hb_eol()

    // Tipo de data/período programado para a entrega: 0 - Sem data definida; 1 - Na data; 2 - Até a data; 3 - A partir da data; 4 – No período
    do case
        case (cte:tpPer == '0')
            ::body += '                "semData": {' + hb_eol()
            ::body += '                    "tpPer": 0' + hb_eol()
            ::body += '                },' + hb_eol()
        case (cte:tpPer $ '1|2|3')
            ::body += '                "comData": {' + hb_eol()
            ::body += '                    "tpPer": ' + cte:tpPer + ',' + hb_eol()
            ::body += '                    "dProg": "' + cte:dProg + '"' + hb_eol()
            ::body += '                },' + hb_eol()
        case (cte:tpPer == '4')
            ::body += '                "noPeriodo": {' + hb_eol()
            ::body += '                    "tpPer": ' + cte:tpPer + ',' + hb_eol()
            ::body += '                    "dIni": "' + cte:dIni + '",' + hb_eol()
            ::body += '                    "dFim": "' + cte:dFim + '"' + hb_eol()
            ::body += '                },' + hb_eol()
    endcase

    // Tipo de hora/período programado para a entrega: 0 - Sem hora definida; 1 - Na hora; 2 - Até a hora; 3 - A partir da hora; 4 – No intervalo de tempo
    do case
        case (cte:tpHor == '0')
            ::body += '                "semHora": {' + hb_eol()
            ::body += '                    "tpHor": 0' + hb_eol()
            ::body += '                },' + hb_eol()
        case (cte:tpHor $ '1|2|3')
            ::body += '                "comHora": {' + hb_eol()
            ::body += '                    "tpHor": ' + cte:tpHor + ',' + hb_eol()
            ::body += '                    "hProg": "' + cte:hProg + '"' + hb_eol()
            ::body += '                },' + hb_eol()
        case (cte:tpHor == '4')
            ::body += '                "noInter": {' + hb_eol()
            ::body += '                    "tpHor": ' + cte:tpHor + ',' + hb_eol()
            ::body += '                    "hIni": "' + cte:hIni + '",' + hb_eol()
            ::body += '                    "hFim": "' + cte:hFim + '"' + hb_eol()
            ::body += '                },' + hb_eol()
    endcase

    // Fecha Entrega
    ::body += '            },' + hb_eol()
    ::body += '            "origCalc": "' + cte:xMunIni + '",' + hb_eol()
    ::body += '            "destCalc": "' + cte:xMunFim + '",' + hb_eol()

    if !Empty(cte:xObs)
        ::body += '            "xObs": "' + cte:xObs + '",' + hb_eol()
    endif

    if !Empty(cte:obs_contr)
        ::body += '            "ObsCont": [' + hb_eol()
        for each obs in cte:obs_contr
            ::body += '                {' + hb_eol()
            ::body += '                    "xCampo": "' + obs["xCampo"] + '",' + hb_eol()
            ::body += '                    "xTexto": "' + obs["xTexto"] + '"' + hb_eol()
            ::body += '                },' + hb_eol()
        next
        // Remove a última vírgula do objeto
        ::body := hb_ULeft(::body, hmg_len(::body)-1)
        ::body += '            ],' + hb_eol()
    endif

    if !Empty(cte:obs_fisco)
        ::body += '            "ObsFisco": [' + hb_eol()
        for each obs in cte:obs_fisco
            ::body += '                {' + hb_eol()
            ::body += '                    "xCampo": "' + obs["xCampo"] + '",' + hb_eol()
            ::body += '                    "xTexto": "' + obs["xTexto"] + '"' + hb_eol()
            ::body += '                },' + hb_eol()
        next
        // Remove a última vírgula do objeto
        ::body := hb_ULeft(::body, hmg_len(::body)-1)
        ::body += '            ]' + hb_eol()    // Fecha ObsFisco
    endif

    // Fecha compl
    ::body += '        },' + hb_eol()
    ::body += '        "emit": {' + hb_eol()
    ::body += '            "CNPJ": "' + cte:emitente:CNPJ + '",' + hb_eol()
    // ::body += '            "CPF": "' + cte:rem_cpf + '",' + hb_eol()
    ::body += '            "IE": "' + cte:emitente:IE + '",' + hb_eol()
    // ::body += '            "IEST": "' + cte:emitente:CNPJ + '",' + hb_eol()
    ::body += '            "xNome": "' + cte:emitente:xNome + '",' + hb_eol()
    ::body += '            "xFant": "' + cte:emitente:xFant + '",' + hb_eol()
    ::body += '            "enderEmit": {' + hb_eol()
    ::body += '                "xLgr": "' + cte:emitente:xLgr + '",' + hb_eol()
    ::body += '                "nro": "' + cte:emitente:nro + '",' + hb_eol()
    ::body += '                "xCpl": "' + cte:emitente:xCpl + '",' + hb_eol()
    ::body += '                "xBairro": "' + cte:emitente:xBairro + '",' + hb_eol()
    ::body += '                "cMun": "' + cte:emitente:cMunEnv + '",' + hb_eol()
    ::body += '                "xMun": "' + cte:emitente:xMunEnv + '",' + hb_eol()
    ::body += '                "CEP": "' + cte:emitente:CEP + '",' + hb_eol()
    ::body += '                "UF": "' + cte:emitente:UF + '",' + hb_eol()
    ::body += '                "fone": "' + cte:emitente:fone + '"' + hb_eol()
    ::body += '            },' + hb_eol()

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

    ::body += '            "CRT": ' + cte:emitente:CRT + hb_eol()
    // Fecha emit
    ::body += '        },' + hb_eol()
    ::body += '        "rem": {' + hb_eol()

    if Empty(cte:rem_cnpj)
        ::body += '            "CPF": "' + cte:rem_cpf + '",' + hb_eol()
    else
        ::body += '            "CNPJ": "' + cte:rem_cnpj + '",' + hb_eol()
        ::body += '            "IE": "",' + hb_eol()
    endif

    ::body += '            "xNome": "' + cte:rem_razao_social + '",' + hb_eol()
    ::body += '            "xFant": "' + cte:rem_nome_fantasia + '",' + hb_eol()
    ::body += '            "fone": "' + cte:rem_fone + '",' + hb_eol()
    ::body += '            "enderReme": {' + hb_eol()
    ::body += '                "xLgr": "' + cte:rem_end_logradouro + '",' + hb_eol()
    ::body += '                "nro": "' + cte:rem_end_numero + '",' + hb_eol()
    ::body += '                "xCpl": "' + cte:rem_end_complemento + '",' + hb_eol()
    ::body += '                "xBairro": "' + cte:rem_end_bairro + '",' + hb_eol()
    ::body += '                "cMun": "' + cte:rem_cid_codigo_municipio + '",' + hb_eol()
    ::body += '                "xMun": "' + cte:rem_cid_municipio + '",' + hb_eol()
    ::body += '                "CEP": "' + cte:rem_end_cep + '",' + hb_eol()
    ::body += '                "UF": "' + cte:rem_cid_uf + '",' + hb_eol()
    ::body += '                "cPais": "1058",' + hb_eol()
    ::body += '                "xPais": "BRASIL"' + hb_eol()

    if Empty(cte:rem_email)
        ::body += '            }' + hb_eol()
    else
        ::body += '            },' + hb_eol()
        ::body += '            "email": "' + cte:rem_email + '"' + hb_eol()
    endif

    // Fechou rem
    ::body += '        },' + hb_eol()

    // Abre exped
    ::body += '        "exped": {' + hb_eol()
    if Empty(cte:exp_cnpj)
        ::body += '            "CPF": "' + cte:exp_cpf + '",' + hb_eol()
    else
        ::body += '            "CNPJ": "' + cte:exp_cnpj + '",' + hb_eol()
        ::body += '            "IE": "",' + hb_eol()
    endif

    ::body += '            "xNome": "' + cte:exp_razao_social + '",' + hb_eol()
    ::body += '            "xFant": "' + cte:exp_nome_fantasia + '",' + hb_eol()
    ::body += '            "fone": "' + cte:exp_fone + '",' + hb_eol()
    ::body += '            "enderExped": {' + hb_eol()
    ::body += '                "xLgr": "' + cte:exp_end_logradouro + '",' + hb_eol()
    ::body += '                "nro": "' + cte:exp_end_numero + '",' + hb_eol()
    ::body += '                "xCpl": "' + cte:exp_end_complemento + '",' + hb_eol()
    ::body += '                "xBairro": "' + cte:exp_end_bairro + '",' + hb_eol()
    ::body += '                "cMun": "' + cte:exp_cid_codigo_municipio + '",' + hb_eol()
    ::body += '                "xMun": "' + cte:exp_cid_municipio + '",' + hb_eol()
    ::body += '                "CEP": "' + cte:exp_end_cep + '",' + hb_eol()
    ::body += '                "UF": "' + cte:exp_cid_uf + '",' + hb_eol()
    ::body += '                "cPais": "1058",' + hb_eol()
    ::body += '                "xPais": "BRASIL"' + hb_eol()

    if Empty(cte:exp_email)
        ::body += '            }' + hb_eol()
    else
        ::body += '            },' + hb_eol()
        ::body += '            "email": "' + cte:exp_email + '"' + hb_eol()
    endif
    ::body += '            },' + hb_eol()

    // Fecha exped
    ::body += '        },' + hb_eol()
    // Abre receb
    ::body += '        "receb": {' + hb_eol()

    if Empty(cte:rec_cnpj)
        ::body += '            "CPF": "' + cte:rec_cpf + '",' + hb_eol()
    else
        ::body += '            "CNPJ": "' + cte:rec_cnpj + '",' + hb_eol()
        ::body += '            "IE": "",' + hb_eol()
    endif

    ::body += '            "xNome": "' + cte:rec_razao_social + '",' + hb_eol()
    ::body += '            "xFant": "' + cte:rec_nome_fantasia + '",' + hb_eol()
    ::body += '            "fone": "' + cte:rec_fone + '",' + hb_eol()
    ::body += '            "enderReceb": {' + hb_eol()
    ::body += '                "xLgr": "' + cte:rec_end_logradouro + '",' + hb_eol()
    ::body += '                "nro": "' + cte:rec_end_numero + '",' + hb_eol()
    ::body += '                "xCpl": "' + cte:rec_end_complemento + '",' + hb_eol()
    ::body += '                "xBairro": "' + cte:rec_end_bairro + '",' + hb_eol()
    ::body += '                "cMun": "' + cte:rec_cid_codigo_municipio + '",' + hb_eol()
    ::body += '                "xMun": "' + cte:rec_cid_municipio + '",' + hb_eol()
    ::body += '                "CEP": "' + cte:rec_end_cep + '",' + hb_eol()
    ::body += '                "UF": "' + cte:rec_cid_uf + '",' + hb_eol()
    ::body += '                "cPais": "1058",' + hb_eol()
    ::body += '                "xPais": "BRASIL"' + hb_eol()

    if Empty(cte:rec_email)
        ::body += '            }' + hb_eol()
    else
        ::body += '            },' + hb_eol()
        ::body += '            "email": "' + cte:rec_email + '"' + hb_eol()
    endif

    // Fecho receb
    ::body += '        },' + hb_eol()
    // Abre dest
    ::body += '        "dest": {' + hb_eol()

    if Empty(cte:des_cnpj)
        ::body += '            "CPF": "' + cte:des_cpf + '",' + hb_eol()
    else
        ::body += '            "CNPJ": "' + cte:des_cnpj + '",' + hb_eol()
        ::body += '            "IE": "",' + hb_eol()
    endif

    ::body += '            "xNome": "' + cte:des_razao_social + '",' + hb_eol()
    ::body += '            "xFant": "' + cte:des_nome_fantasia + '",' + hb_eol()
    ::body += '            "fone": "' + cte:des_fone + '",' + hb_eol()
    ::body += '            "ISUF": "",' + hb_eol()
    ::body += '            "enderDest": {' + hb_eol()
    ::body += '                "xLgr": "' + cte:des_end_logradouro + '",' + hb_eol()
    ::body += '                "nro": "' + cte:des_end_numero + '",' + hb_eol()
    ::body += '                "xCpl": "' + cte:des_end_complemento + '",' + hb_eol()
    ::body += '                "xBairro": "' + cte:des_end_bairro + '",' + hb_eol()
    ::body += '                "cMun": "' + cte:des_cid_codigo_municipio + '",' + hb_eol()
    ::body += '                "xMun": "' + cte:des_cid_municipio + '",' + hb_eol()
    ::body += '                "CEP": "' + cte:des_end_cep + '",' + hb_eol()
    ::body += '                "UF": "' + cte:des_cid_uf + '",' + hb_eol()
    ::body += '                "cPais": "1058",' + hb_eol()
    ::body += '                "xPais": "BRASIL"' + hb_eol()

    if Empty(cte:des_email)
        ::body += '            }' + hb_eol()
    else
        ::body += '            },' + hb_eol()
        ::body += '            "email": "' + cte:des_email + '"' + hb_eol()
    endif

    // Fecha dest
    ::body += '        },' + hb_eol()
    // Abre vPrest
    ::body += '        "vPrest": {' + hb_eol()
    ::body += '            "vTPrest": ' + cte:vTPrest + ',' + hb_eol()

    if Empty(cte:comp_calc)
        ::body += '            "vRec": ' + cte:vTPrest + hb_eol()
    else
        ::body += '            "vRec": ' + cte:vTPrest + ',' + hb_eol()
        ::body += '            "Comp": [' + hb_eol()
        for each comp in cte:comp_calc
            ::body += '                {' + hb_eol()
            ::body += '                    "xNome": "' + comp['xNome'] + '",' + hb_eol()
            ::body += '                    "vComp": ' + comp['vComp'] + hb_eol()
            ::body += '                },' + hb_eol()
        next
        // Remove a última vírgula do objeto
        ::body := hb_ULeft(::body, hmg_len(::body)-1)
        ::body += '            ]' + hb_eol()
    endif

    // Fecha vPrest
    ::body += '        },' + hb_eol()
    // Abre imp
    ::body += '        "imp": {' + hb_eol()
    ::body += '            "ICMS": {' + hb_eol()

    switch cte:codigo_sit_tributaria
        case "00 - Tributação normal do ICMS"
            ::body += '                "ICMS00": {' + hb_eol()
            ::body += '                    "CST": "00",' + hb_eol()
            ::body += '                    "vBC": ' + cte:vBC + ',' + hb_eol()
            ::body += '                    "pICMS": ' + cte:pICMS + ',' + hb_eol()
            ::body += '                    "vICMS": ' + cte:vICMS + '' + hb_eol()
            exit
        case "20 - Tributação com redução de BC do ICMS"
            ::body += '                "ICMS20": {' + hb_eol()
            ::body += '                    "CST": "20",' + hb_eol()
            ::body += '                    "pRedBC": ' + cte:pRedBC + ',' + hb_eol()
            ::body += '                    "vBC": ' + cte:vBC + ',' + hb_eol()
            ::body += '                    "pICMS": ' + cte:pICMS + ',' + hb_eol()
            ::body += '                    "vICMS": ' + cte:vICMS + '' + hb_eol()
            exit
        case "60 - ICMS cobrado anteriormente por substituição tributária"
            ::body += '                "ICMS60": {' + hb_eol()
            ::body += '                    "CST": "60",' + hb_eol()
            ::body += '                    "vBCSTRet": ' + cte:vBC + ',' + hb_eol()
            ::body += '                    "vICMSSTRet": ' + cte:vICMS + ',' + hb_eol()
            ::body += '                    "pICMSSTRet": ' + cte:pICMS + ',' + hb_eol()
            ::body += '                    "vCred": ' + cte:vCred + '' + hb_eol()
            exit
        case "90 - ICMS outros"
            ::body += '                "ICMS90": {
                ::body += '                    "CST": "90",' + hb_eol()
                ::body += '                    "pRedBC": ' + cte:pRedBC + ',' + hb_eol()
                ::body += '                    "vBC": ' + cte:vBC + ',' + hb_eol()
                ::body += '                    "pICMS": ' + cte:pICMS + ',' + hb_eol()
                ::body += '                    "vICMS": ' + cte:vICMS + ',' + hb_eol()
                ::body += '                    "vCred": ' + cte:vCred + hb_eol()
                exit
        case "90 - ICMS devido à UF de origem da prestação, quando diferente da UF emitente"
            ::body += '                "ICMSOutraUF": {' + hb_eol()
            ::body += '                    "CST": "90",' + hb_eol()
            ::body += '                    "pRedBCOutraUF": ' + cte:pRedBC + ',' + hb_eol()
            ::body += '                    "vBCOutraUF": ' + cte:vBC + ',' + hb_eol()
            ::body += '                    "pICMSOutraUF": ' + cte:pICMS + ',' + hb_eol()
            ::body += '                    "vICMSOutraUF": ' + cte:vICMS + hb_eol()
            exit
        case "SIMPLES NACIONAL"
            ::body += '                "ICMSSN": {' + hb_eol()
            ::body += '                    "CST": "90",' + hb_eol()
            ::body += '                    "indSN": 1' + hb_eol()
            exit
    endswitch

    if (cte:codigo_sit_tributaria $ "40|41|51")
        // 45 - ICMS Isento, não Tributado ou diferido
        ::body += '                "ICMS45": {' + hb_eol()
        ::body += '                    "CST": "' + cte:codigo_sit_tributaria + '"' + hb_eol()
    endif

    ::body += '                }' + hb_eol()    // Fecha ICMS
    ::body += '                "vTotTrib": ' + cte:vTotTrib + ',' + hb_eol()
    ::body += '                "infAdFisco": "' + cte:infAdFisco + '",' + hb_eol()

    if !Empty(::calc_difal)

       ::body += '                "ICMSUFFim": {' + hb_eol()
       ::body += '                    "vBCUFFim": ' + cte:vTPrest + ',' + hb_eol()
       ::body += '                    "pFCPUFFim": ' + cte:calc_difal["pFCPUFFim"] + ',' + hb_eol()
       ::body += '                    "pICMSUFFim": ' + cte:calc_difal["pICMSUFFim"] + ',' + hb_eol()
       ::body += '                    "pICMSInter": ' + cte:calc_difal["pICMSInter"] + ',' + hb_eol()
       ::body += '                    "vFCPUFFim": ' + cte:calc_difal["vFCPUFFim"] + ',' + hb_eol()
       ::body += '                    "vICMSUFFim": ' + cte:calc_difal["vICMSUFFim"] + ',' + hb_eol()
       ::body += '                    "vICMSUFIni": ' + cte:calc_difal["vICMSUFIni"] + hb_eol()
       ::body += '                }' + hb_eol()

    endif

    ::body += '            },' + hb_eol()   // Fecha ICMS
    ::body += '        },' + hb_eol()       // Fecha imp
    ::body += '        "infCTeNorm": {' + hb_eol()
    ::body += '            "infCarga": {' + hb_eol()
    ::body += '                "vCarga": ' + cte:vCarga + ',' + hb_eol()
    ::body += '                "proPred": "' + cte:proPred + '",' + hb_eol()
    ::body += '                "xOutCat": "' + cte:xOutCat + '",' + hb_eol()
    ::body += '                "infQ": [' + hb_eol()
    ::body += '                    {' + hb_eol()
    ::body += '                        "cUnid": "01",' + hb_eol()
    ::body += '                        "tpMed": "PESO BRUTO",' + hb_eol()
    ::body += '                        "qCarga": ' + LTrim(Transform(Val(cte:peso_bruto), "99999999999.9999")) + hb_eol()
    ::body += '                    },' + hb_eol()
    ::body += '                    {' + hb_eol()
    ::body += '                        "cUnid": "01",' + hb_eol()
    ::body += '                        "tpMed": "PESO BC",' + hb_eol()
    ::body += '                        "qCarga": ' + LTrim(Transform(Val(cte:peso_bc), "99999999999.9999")) + hb_eol()
    ::body += '                    },' + hb_eol()
    ::body += '                    {' + hb_eol()
    ::body += '                        "cUnid": "01",' + hb_eol()
    ::body += '                        "tpMed": "PESO CUBADO",' + hb_eol()
    ::body += '                        "qCarga": ' + LTrim(Transform(Val(cte:peso_cubado), "99999999999.9999")) + hb_eol()
    ::body += '                    },' + hb_eol()
    ::body += '                    {' + hb_eol()
    ::body += '                        "cUnid": "00",' + hb_eol()
    ::body += '                        "tpMed": "CUBAGEM",' + hb_eol()
    ::body += '                        "qCarga": ' + LTrim(Transform(Val(cte:cubagem_m3), "99999999999.9999")) + hb_eol()
    ::body += '                    },' + hb_eol()
    ::body += '                    {' + hb_eol()
    ::body += '                        "cUnid": "03",' + hb_eol()
    ::body += '                        "tpMed": "VOLS.",' + hb_eol()
    ::body += '                        "qCarga": ' + LTrim(Transform(Val(cte:qtde_volumes), "99999999999.9999")) + hb_eol()
    ::body += '                    },' + hb_eol()
    ::body += '                ]' + hb_eol()
    // ::body += '                "vCargaAverb": 0' + hb_eol()
    ::body += '            },' + hb_eol()   // Fecha infCarga
    ::body += '            "infDoc": {' + hb_eol()
    ::body += '                "infNF": [' + hb_eol()
    ::body += '                    {' + hb_eol()
    ::body += '                        "nRoma": "",' + hb_eol()
    ::body += '                        "nPed": "",' + hb_eol()
    ::body += '                        "mod": "",' + hb_eol()
    ::body += '                        "serie": "",' + hb_eol()
    ::body += '                        "nDoc": "",' + hb_eol()
    ::body += '                        "dEmi": "2019-08-24",' + hb_eol()
    ::body += '                        "vBC": 0,' + hb_eol()
    ::body += '                        "vICMS": 0,' + hb_eol()
    ::body += '                        "vBCST": 0,' + hb_eol()
    ::body += '                        "vST": 0,' + hb_eol()
    ::body += '                        "vProd": 0,' + hb_eol()
    ::body += '                        "vNF": 0,' + hb_eol()
    ::body += '                        "nCFOP": "",' + hb_eol()
    ::body += '                        "nPeso": 0,' + hb_eol()
    ::body += '                        "PIN": "",' + hb_eol()
    ::body += '                        "dPrev": "2019-08-24",' + hb_eol()
    ::body += '                    }' + hb_eol()
    ::body += '                ],' + hb_eol()
    ::body += '                "infNFe": [' + hb_eol()
    ::body += '                    {' + hb_eol()
    ::body += '                        "chave": "string",' + hb_eol()
    ::body += '                        "PIN": "string",' + hb_eol()
    ::body += '                    }' + hb_eol()
    ::body += '                ],' + hb_eol()
    ::body += '                "infOutros": [' + hb_eol()
    ::body += '                    {' + hb_eol()
    ::body += '                        "tpDoc": "string",' + hb_eol()
    ::body += '                        "descOutros": "string",' + hb_eol()
    ::body += '                        "nDoc": "string",' + hb_eol()
    ::body += '                        "dEmi": "2019-08-24",' + hb_eol()
    ::body += '                        "vDocFisc": 0' + hb_eol()
    ::body += '                    }' + hb_eol()
    ::body += '                ]' + hb_eol()
    ::body += '            },' + hb_eol()
    ::body += '            "docAnt": {' + hb_eol()
    ::body += '                "emiDocAnt": [' + hb_eol()
    ::body += '                    {' + hb_eol()
    ::body += '                        "idDocAntPap": [' + hb_eol()
    ::body += '                            {' + hb_eol()
    ::body += '                                "tpDoc": null,' + hb_eol()
    ::body += '                                "serie": null,' + hb_eol()
    ::body += '                                "subser": null,' + hb_eol()
    ::body += '                                "nDoc": null,' + hb_eol()
    ::body += '                                "dEmi": null' + hb_eol()
    ::body += '                            }' + hb_eol()
    ::body += '                        ],' + hb_eol()
    ::body += '                        "idDocAntEle": [' + hb_eol()
    ::body += '                            {' + hb_eol()
    ::body += '                                "chCTe": null' + hb_eol()
    ::body += '                            }' + hb_eol()
    ::body += '                        ]' + hb_eol()
    ::body += '                    }' + hb_eol()
    ::body += '                ]' + hb_eol()
    ::body += '            },' + hb_eol()
    ::body += '            "infModal": {' + hb_eol()
    ::body += '                "versaoModal": "string",' + hb_eol()
    ::body += '                "rodo": {' + hb_eol()
    ::body += '                    "RNTRC": "string",' + hb_eol()
    ::body += '                    "occ": [' + hb_eol()
    ::body += '                        {' + hb_eol()
    ::body += '                            "serie": "string",' + hb_eol()
    ::body += '                            "nOcc": 0,' + hb_eol()
    ::body += '                            "dEmi": "2019-08-24",' + hb_eol()
    ::body += '                            "emiOcc": {}' + hb_eol()
    ::body += '                        }' + hb_eol()
    ::body += '                    ]' + hb_eol()
    ::body += '                },' + hb_eol()
    ::body += '                "aereo": {' + hb_eol()
    ::body += '                    "nMinu": 0,' + hb_eol()
    ::body += '                    "nOCA": "string",' + hb_eol()
    ::body += '                    "dPrevAereo": "2019-08-24",' + hb_eol()
    ::body += '                    "natCarga": {' + hb_eol()
    ::body += '                        "xDime": "string",' + hb_eol()
    ::body += '                        "cInfManu": ["string"]' + hb_eol()
    ::body += '                    },' + hb_eol()
    ::body += '                    "tarifa": {' + hb_eol()
    ::body += '                        "CL": "string",' + hb_eol()
    ::body += '                        "cTar": "string",' + hb_eol()
    ::body += '                        "vTar": 0' + hb_eol()
    ::body += '                    },' + hb_eol()
    ::body += '                    "peri": [' + hb_eol()
    ::body += '                        {' + hb_eol()
    ::body += '                            "nONU": "string",' + hb_eol()
    ::body += '                            "qTotEmb": "string",' + hb_eol()
    ::body += '                            "infTotAP": {' + hb_eol()
    ::body += '                                "qTotProd": 0,' + hb_eol()
    ::body += '                                "uniAP": 0' + hb_eol()
    ::body += '                            }' + hb_eol()
    ::body += '                        }' + hb_eol()
    ::body += '                    ]' + hb_eol()
    ::body += '                },' + hb_eol()
    // ::body += '             "ferrov": {},' + hb_eol()            // NÃO IMPLEMENTADO
    // ::body += '             "aquav": {},' + hb_eol()             // NÃO IMPLEMENTADO
    // ::body += '             "duto": {},' + hb_eol()              // NÃO IMPLEMENTADO
    // ::body += '             "multimodal": {}' + hb_eol()         // NÃO IMPLEMENTADO
    ::body += '            },' + hb_eol()
    ::body += '            "veicNovos": [' + hb_eol()
    ::body += '                {' + hb_eol()
    ::body += '                    "chassi": "string",' + hb_eol()
    ::body += '                    "cCor": "string",' + hb_eol()
    ::body += '                    "xCor": "string",' + hb_eol()
    ::body += '                    "cMod": "string",' + hb_eol()
    ::body += '                    "vUnit": 0,' + hb_eol()
    ::body += '                    "vFrete": 0' + hb_eol()
    ::body += '                }' + hb_eol()
    ::body += '            ],' + hb_eol()
    // ::body += '            "cobr": {},' + hb_eol()               // NÃO IMPLEMENTADO
    // ::body += '            "infCteSub": {},' + hb_eol()          // NÃO IMPLEMENTADO
    ::body += '            "infGlobalizado": {' + hb_eol()
    ::body += '                "xObs": ""' + hb_eol()
    ::body += '            },' + hb_eol()
    // ::body += '            "infServVinc": {}' + hb_eol()          // NÃO IMPLEMENTADO
    ::body += '        },' + hb_eol()   // Fecha infCTeNorm
    // ::body += '        "infCteComp": []' + hb_eol()              // NÃO IMPLEMENTADO
    ::body += '        "autXML": [' + hb_eol()
    ::body += '            {' + hb_eol()
    ::body += '                "CNPJ": "string",' + hb_eol()
    ::body += '                "CPF": "string"' + hb_eol()
    ::body += '            }' + hb_eol()
    ::body += '        ],' + hb_eol()
    ::body += '        "infRespTec": {' + hb_eol()
    ::body += '            "CNPJ": "string",' + hb_eol()
    ::body += '            "xContato": "string",' + hb_eol()
    ::body += '            "email": "string",' + hb_eol()
    ::body += '            "fone": "string",' + hb_eol()
    ::body += '            "idCSRT": 0,' + hb_eol()
    ::body += '            "hashCSRT": "string"' + hb_eol()
    ::body += '        },' + hb_eol()
    // ::body += '        "infSolicNFF": {}' + hb_eol()     // NÃO É O CASO DOS AGENTES DE CARGA
    ::body += '    }' + hb_eol()     // Fecha infCte
    ::body += '    "infCTeSupl": {}' + hb_eol()     // NÃO IMPLEMENTADO
    ::body += '    "ambiente": "",' + hb_eol()     // Fecha infCte
    ::body += '    "referencia": ""' + hb_eol()     // Fecha infCte
    ::body += '}'                    // Fecha json

return nil
