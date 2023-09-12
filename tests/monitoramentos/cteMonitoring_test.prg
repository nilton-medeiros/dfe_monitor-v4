/*
 Testa se o sistema chegou até aqui através do cliclo de monitoramento (Timer_DFE) a cada 10 segundos
 Verifica se o objeto cte está com os dados corretos vindo do banco de dados remoto ou do dados-fake
*/

procedure testSubmit(cte)
    local msgLog
    saveLog("Entrou no testSubmit com o parâmetro objeto cte")

    msgLog := "TESTANDO MONITORAMENTO DE CTEs" + hb_eol() + hb_eol()
    msgLog += ">> ESPERA SER CRIADO ABAIXO UM JSON COM TODAS AS CHAVES E VALORES DO OBJETO cte <<" + hb_eol() + hb_eol()
    msgLog += '{' + hb_eol()
    msgLog += space(4) + '"test":"TEST-SUBMIT",' + hb_eol()
    msgLog += space(4) + '"id":"' + cte:id + '",' + hb_eol()
    msgLog += space(4) + '"emp_id":"' + cte:emp_id + '",' + hb_eol()
    msgLog += space(4) + '"versao_xml":"' + cte:versao_xml + '",' + hb_eol()
    msgLog += space(4) + '"dhEmi":"' + cte:dhEmi + '",' + hb_eol()
    msgLog += space(4) + '"modelo":"' + cte:modelo + '",' + hb_eol()
    msgLog += space(4) + '"serie":"' + cte:serie + '",' + hb_eol()
    msgLog += space(4) + '"nCT":"' + cte:nCT + '",' + hb_eol()
    msgLog += space(4) + '"cCT":"' + cte:cCT + '",' + hb_eol()
    msgLog += space(4) + '"situacao":"' + cte:situacao + '",' + hb_eol()
    msgLog += space(4) + '"chCTe":"' + cte:chCTe + '",' + hb_eol()
    msgLog += space(4) + '"nProt":"' + cte:nProt + '",' + hb_eol()
    msgLog += space(4) + '"CFOP":"' + cte:CFOP + '",' + hb_eol()
    msgLog += space(4) + '"natOp":"' + cte:natOp + '",' + hb_eol()
    msgLog += space(4) + '"tpEmis":"' + cte:tpEmis + '",' + hb_eol()
    msgLog += space(4) + '"tpCTe":"' + cte:tpCTe + '",' + hb_eol()
    msgLog += space(4) + '"modal":"' + cte:modal + '",' + hb_eol()
    msgLog += space(4) + '"tpServ":"' + cte:tpServ + '",' + hb_eol()
    msgLog += space(4) + '"cMunIni":"' + cte:cMunIni + '",' + hb_eol()
    msgLog += space(4) + '"xMunIni":"' + cte:xMunIni + '",' + hb_eol()
    msgLog += space(4) + '"UFIni":"' + cte:UFIni + '",' + hb_eol()
    msgLog += space(4) + '"cMunFim":"' + cte:cMunFim + '",' + hb_eol()
    msgLog += space(4) + '"xMunFim":"' + cte:xMunFim + '",' + hb_eol()
    msgLog += space(4) + '"UFFim":"' + cte:UFFim + '",' + hb_eol()
    msgLog += space(4) + '"retira":"' + cte:retira + '",' + hb_eol()
    msgLog += space(4) + '"xDetRetira":"' + cte:xDetRetira + '",' + hb_eol()
    msgLog += space(4) + '"clie_tomador_id":"' + cte:clie_tomador_id + '",' + hb_eol()
    msgLog += space(4) + '"indIEToma":"' + cte:indIEToma + '",' + hb_eol()
    msgLog += space(4) + '"tom_ie_isento":"' + cte:tom_ie_isento + '",' + hb_eol()
    msgLog += space(4) + '"tomador":"' + cte:tomador + '",' + hb_eol()
    msgLog += space(4) + '"tom_cnpj":"' + cte:tom_cnpj + '",' + hb_eol()
    msgLog += space(4) + '"tom_ie":"' + cte:tom_ie + '",' + hb_eol()
    msgLog += space(4) + '"tom_cpf":"' + cte:tom_cpf + '",' + hb_eol()
    msgLog += space(4) + '"tom_xFant":"' + cte:tom_xFant + '",' + hb_eol()
    msgLog += space(4) + '"tom_xNome":"' + cte:tom_xNome + '",' + hb_eol()
    msgLog += space(4) + '"tom_fone":"' + cte:tom_fone + '",' + hb_eol()
    msgLog += space(4) + '"tom_end_logradouro":"' + cte:tom_end_logradouro + '",' + hb_eol()
    msgLog += space(4) + '"tom_end_numero":"' + cte:tom_end_numero + '",' + hb_eol()
    msgLog += space(4) + '"tom_end_complemento":"' + cte:tom_end_complemento + '",' + hb_eol()
    msgLog += space(4) + '"tom_end_bairro":"' + cte:tom_end_bairro + '",' + hb_eol()
    msgLog += space(4) + '"tom_cid_codigo_municipio":"' + cte:tom_cid_codigo_municipio + '",' + hb_eol()
    msgLog += space(4) + '"tom_cid_municipio":"' + cte:tom_cid_municipio + '",' + hb_eol()
    msgLog += space(4) + '"tom_end_cep":"' + cte:tom_end_cep + '",' + hb_eol()
    msgLog += space(4) + '"tom_cid_uf":"' + cte:tom_cid_uf + '",' + hb_eol()
    msgLog += space(4) + '"xCaracAd":"' + cte:xCaracAd + '",' + hb_eol()
    msgLog += space(4) + '"xCaracSer":"' + cte:xCaracSer + '",' + hb_eol()
    msgLog += space(4) + '"xEmi":"' + cte:xEmi + '",' + hb_eol()
    msgLog += space(4) + '"xOrig":"' + cte:xOrig + '",' + hb_eol()
    msgLog += space(4) + '"xPass":"' + cte:xPass + '",' + hb_eol()
    msgLog += space(4) + '"xDest":"' + cte:xDest + '",' + hb_eol()
    msgLog += space(4) + '"tpPer":"' + cte:tpPer + '",' + hb_eol()
    msgLog += space(4) + '"dProg":"' + cte:dProg + '",' + hb_eol()
    msgLog += space(4) + '"dIni":"' + cte:dIni + '",' + hb_eol()
    msgLog += space(4) + '"dFim":"' + cte:dFim + '",' + hb_eol()
    msgLog += space(4) + '"tpHor":"' + cte:tpHor + '",' + hb_eol()
    msgLog += space(4) + '"hProg":"' + cte:hProg + '",' + hb_eol()
    msgLog += space(4) + '"hIni":"' + cte:hIni + '",' + hb_eol()
    msgLog += space(4) + '"hFim":"' + cte:hFim + '",' + hb_eol()
    msgLog += space(4) + '"xObs":"' + cte:xObs + '",' + hb_eol()
    msgLog += space(4) + '"clie_remetente_id":"' + cte:clie_remetente_id + '",' + hb_eol()
    msgLog += space(4) + '"rem_razao_social":"' + cte:rem_razao_social + '",' + hb_eol()
    msgLog += space(4) + '"rem_nome_fantasia":"' + cte:rem_nome_fantasia + '",' + hb_eol()
    msgLog += space(4) + '"rem_cnpj":"' + cte:rem_cnpj + '",' + hb_eol()
    msgLog += space(4) + '"rem_ie":"' + cte:rem_ie + '",' + hb_eol()
    msgLog += space(4) + '"rem_cpf":"' + cte:rem_cpf + '",' + hb_eol()
    msgLog += space(4) + '"rem_fone":"' + cte:rem_fone + '",' + hb_eol()
    msgLog += space(4) + '"rem_end_logradouro":"' + cte:rem_end_logradouro + '",' + hb_eol()
    msgLog += space(4) + '"rem_end_numero":"' + cte:rem_end_numero + '",' + hb_eol()
    msgLog += space(4) + '"rem_end_complemento":"' + cte:rem_end_complemento + '",' + hb_eol()
    msgLog += space(4) + '"rem_end_bairro":"' + cte:rem_end_bairro + '",' + hb_eol()
    msgLog += space(4) + '"rem_cid_codigo_municipio":"' + cte:rem_cid_codigo_municipio + '",' + hb_eol()
    msgLog += space(4) + '"rem_cid_municipio":"' + cte:rem_cid_municipio + '",' + hb_eol()
    msgLog += space(4) + '"rem_end_cep":"' + cte:rem_end_cep + '",' + hb_eol()
    msgLog += space(4) + '"rem_cid_uf":"' + cte:rem_cid_uf + '",' + hb_eol()
    msgLog += space(4) + '"rem_icms":"' + cte:rem_icms + '",' + hb_eol()
    msgLog += space(4) + '"clie_destinatario_id":"' + cte:clie_destinatario_id + '",' + hb_eol()
    msgLog += space(4) + '"des_razao_social":"' + cte:des_razao_social + '",' + hb_eol()
    msgLog += space(4) + '"des_nome_fantasia":"' + cte:des_nome_fantasia + '",' + hb_eol()
    msgLog += space(4) + '"des_cnpj":"' + cte:des_cnpj + '",' + hb_eol()
    msgLog += space(4) + '"des_ie":"' + cte:des_ie + '",' + hb_eol()
    msgLog += space(4) + '"des_cpf":"' + cte:des_cpf + '",' + hb_eol()
    msgLog += space(4) + '"des_fone":"' + cte:des_fone + '",' + hb_eol()
    msgLog += space(4) + '"des_end_logradouro":"' + cte:des_end_logradouro + '",' + hb_eol()
    msgLog += space(4) + '"des_end_numero":"' + cte:des_end_numero + '",' + hb_eol()
    msgLog += space(4) + '"des_end_complemento":"' + cte:des_end_complemento + '",' + hb_eol()
    msgLog += space(4) + '"des_end_bairro":"' + cte:des_end_bairro + '",' + hb_eol()
    msgLog += space(4) + '"des_cid_codigo_municipio":"' + cte:des_cid_codigo_municipio + '",' + hb_eol()
    msgLog += space(4) + '"des_cid_municipio":"' + cte:des_cid_municipio + '",' + hb_eol()
    msgLog += space(4) + '"des_end_cep":"' + cte:des_end_cep + '",' + hb_eol()
    msgLog += space(4) + '"des_cid_uf":"' + cte:des_cid_uf + '",' + hb_eol()
    msgLog += space(4) + '"des_icms":"' + cte:des_icms + '",' + hb_eol()
    msgLog += space(4) + '"clie_expedidor_id":"' + cte:clie_expedidor_id + '",' + hb_eol()
    msgLog += space(4) + '"exp_razao_social":"' + cte:exp_razao_social + '",' + hb_eol()
    msgLog += space(4) + '"exp_nome_fantasia":"' + cte:exp_nome_fantasia + '",' + hb_eol()
    msgLog += space(4) + '"exp_cnpj":"' + cte:exp_cnpj + '",' + hb_eol()
    msgLog += space(4) + '"exp_ie":"' + cte:exp_ie + '",' + hb_eol()
    msgLog += space(4) + '"exp_cpf":"' + cte:exp_cpf + '",' + hb_eol()
    msgLog += space(4) + '"exp_fone":"' + cte:exp_fone + '",' + hb_eol()
    msgLog += space(4) + '"exp_end_logradouro":"' + cte:exp_end_logradouro + '",' + hb_eol()
    msgLog += space(4) + '"exp_end_numero":"' + cte:exp_end_numero + '",' + hb_eol()
    msgLog += space(4) + '"exp_end_complemento":"' + cte:exp_end_complemento + '",' + hb_eol()
    msgLog += space(4) + '"exp_end_bairro":"' + cte:exp_end_bairro + '",' + hb_eol()
    msgLog += space(4) + '"exp_cid_codigo_municipio":"' + cte:exp_cid_codigo_municipio + '",' + hb_eol()
    msgLog += space(4) + '"exp_cid_municipio":"' + cte:exp_cid_municipio + '",' + hb_eol()
    msgLog += space(4) + '"exp_end_cep":"' + cte:exp_end_cep + '",' + hb_eol()
    msgLog += space(4) + '"exp_cid_uf":"' + cte:exp_cid_uf + '",' + hb_eol()
    msgLog += space(4) + '"exp_icms":"' + cte:exp_icms + '",' + hb_eol()
    msgLog += space(4) + '"clie_recebedor_id":"' + cte:clie_recebedor_id + '",' + hb_eol()
    msgLog += space(4) + '"rec_razao_social":"' + cte:rec_razao_social + '",' + hb_eol()
    msgLog += space(4) + '"rec_nome_fantasia":"' + cte:rec_nome_fantasia + '",' + hb_eol()
    msgLog += space(4) + '"rec_cnpj":"' + cte:rec_cnpj + '",' + hb_eol()
    msgLog += space(4) + '"rec_ie":"' + cte:rec_ie + '",' + hb_eol()
    msgLog += space(4) + '"rec_cpf":"' + cte:rec_cpf + '",' + hb_eol()
    msgLog += space(4) + '"rec_fone":"' + cte:rec_fone + '",' + hb_eol()
    msgLog += space(4) + '"rec_end_logradouro":"' + cte:rec_end_logradouro + '",' + hb_eol()
    msgLog += space(4) + '"rec_end_numero":"' + cte:rec_end_numero + '",' + hb_eol()
    msgLog += space(4) + '"rec_end_complemento":"' + cte:rec_end_complemento + '",' + hb_eol()
    msgLog += space(4) + '"rec_end_bairro":"' + cte:rec_end_bairro + '",' + hb_eol()
    msgLog += space(4) + '"rec_cid_codigo_municipio":"' + cte:rec_cid_codigo_municipio + '",' + hb_eol()
    msgLog += space(4) + '"rec_cid_municipio":"' + cte:rec_cid_municipio + '",' + hb_eol()
    msgLog += space(4) + '"rec_end_cep":"' + cte:rec_end_cep + '",' + hb_eol()
    msgLog += space(4) + '"rec_cid_uf":"' + cte:rec_cid_uf + '",' + hb_eol()
    msgLog += space(4) + '"rec_icms":"' + cte:rec_icms + '",' + hb_eol()
    msgLog += space(4) + '"vTPrest":"' + cte:vTPrest + '",' + hb_eol()
    msgLog += space(4) + '"vBC":"' + cte:vBC + '",' + hb_eol()
    msgLog += space(4) + '"pICMS":"' + cte:pICMS + '",' + hb_eol()
    msgLog += space(4) + '"vICMS":"' + cte:vICMS + '",' + hb_eol()
    msgLog += space(4) + '"pRedBC":"' + cte:pRedBC + '",' + hb_eol()
    msgLog += space(4) + '"vCred":"' + cte:vCred + '",' + hb_eol()
    msgLog += space(4) + '"codigo_sit_tributaria":"' + cte:codigo_sit_tributaria + '",' + hb_eol()
    msgLog += space(4) + '"vPIS":"' + cte:vPIS + '",' + hb_eol()
    msgLog += space(4) + '"vCOFINS":"' + cte:vCOFINS + '",' + hb_eol()
    msgLog += space(4) + '"vTotTrib":"' + cte:vTotTrib + '",' + hb_eol()
    msgLog += space(4) + '"infAdFisco":"' + cte:infAdFisco + '",' + hb_eol()
    msgLog += space(4) + '"vCarga":"' + cte:vCarga + '",' + hb_eol()
    msgLog += space(4) + '"proPred":"' + cte:proPred + '",' + hb_eol()
    msgLog += space(4) + '"cTar":"' + cte:cTar + '",' + hb_eol()
    msgLog += space(4) + '"xOutCat":"' + cte:xOutCat + '",' + hb_eol()
    msgLog += space(4) + '"peso_bruto":"' + cte:peso_bruto + '",' + hb_eol()
    msgLog += space(4) + '"peso_cubado":"' + cte:peso_cubado + '",' + hb_eol()
    msgLog += space(4) + '"peso_bc":"' + cte:peso_bc + '",' + hb_eol()
    msgLog += space(4) + '"cubagem_m3":"' + cte:cubagem_m3 + '",' + hb_eol()
    msgLog += space(4) + '"qtde_volumes":"' + cte:qtde_volumes + '",' + hb_eol()
    msgLog += space(4) + '"tipo_doc_anexo":"' + cte:tipo_doc_anexo + '",' + hb_eol()
    msgLog += space(4) + '"nOCA":"' + cte:nOCA + '",' + hb_eol()
    msgLog += space(4) + '"dPrevAereo":"' + cte:dPrevAereo + '",' + hb_eol()
    msgLog += space(4) + '"monitor_action":"' + cte:monitor_action + '"' + hb_eol()
    msgLog += "}" + hb_eol() + hb_eol()
    saveLog(msgLog)
    MessageBox("Teste concluído, verificar arquivo de log"+hb_eol()+"O Timer foi desativado", "Teste SUBMIT")
return

procedure testGetFiles(cte)
    local msgLog
    saveLog("Entrou no testGetFiles com o parâmetro objeto cte")
    msgLog := '{' + hb_eol()
    msgLog += space(4) + '"test":"TEST-GETFILES",' + hb_eol()
    msgLog += space(4) + '"id":"' + cte:id + '",' + hb_eol()
    msgLog += "}"
    saveLog(msgLog)
    MessageBox("Teste concluído, verificar arquivo de log", "Teste GETFILES")
return

procedure testCancel(cte)
    local msgLog
    saveLog("Entrou no testCancel com o parâmetro objeto cte")
    msgLog := '{' + hb_eol()
    msgLog += space(4) + '"test":"TEST-CANCEL",' + hb_eol()
    msgLog += space(4) + '"id":"' + cte:id + '",' + hb_eol()
    msgLog += "}"
    saveLog(msgLog)
    MessageBox("Teste concluído, verificar arquivo de log", "Teste CANCEL")
return
