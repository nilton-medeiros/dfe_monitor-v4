#include "hmg.ch"
#include <hbclass.ch>

class TDbConhecimentos
    data ctes
    data ok
    method new() constructor
    method count() setget
end class

method new() class TDbConhecimentos
    local hRow
    local dbCTes, empresa, sql := TSQLString():new()

    sql:setValue("SELECT cte_id AS id, ")
    sql:add("emp_id, ")
    sql:add("cte_versao_leiaute_xml AS versao_xml, ")
    sql:add("cte_data_hora_emissao AS dhEmi, ")
    sql:add("cte_modelo AS modelo, ")
    sql:add("cte_serie AS serie, ")
    sql:add("cte_numero AS nCT, ")
    sql:add("cte_minuta AS cCT, ")
    sql:add("cte_situacao AS situacao, ")
    sql:add("cte_chave AS chCTe, ")
    sql:add("cte_protocolo_autorizacao AS nProt, ")
    sql:add("cte_cfop AS CFOP, ")
    sql:add("cte_natureza_operacao AS natOp, ")
    sql:add("cte_forma_emissao AS tpEmis, ")
    sql:add("cte_tipo_do_cte AS tpCTe, ")
    sql:add("cte_modal AS modal, ")
    sql:add("cte_tipo_servico AS tpServ, ")
    sql:add("cid_origem_codigo_municipio AS cMunIni, ")
    sql:add("cid_origem_municipio AS xMunIni, ")
    sql:add("cid_origem_uf AS UFIni, ")
    sql:add("cid_destino_codigo_municipio AS cMunFim, ")
    sql:add("cid_destino_municipio AS xMunFim, ")
    sql:add("cid_destino_uf AS UFFim, ")
    sql:add("cte_retira AS retira, ")
    sql:add("cte_detalhe_retira AS xDetRetira, ")
    sql:add("clie_tomador_id, ")
    sql:add("tom_icms AS indIEToma, ")
    sql:add("tom_ie_isento, ")
    sql:add("cte_tomador AS tomador, ")
    sql:add("tom_cnpj, ")
    sql:add("tom_ie, ")
    sql:add("tom_cpf, ")
    sql:add("tom_nome_fantasia AS tom_xFant, ")
    sql:add("tom_razao_social AS tom_xNome, ")
    sql:add("tom_fone, ")
    sql:add("tom_end_logradouro, ")
    sql:add("tom_end_numero, ")
    sql:add("tom_end_complemento, ")
    sql:add("tom_end_bairro, ")
    sql:add("tom_cid_codigo_municipio, ")
    sql:add("tom_cid_municipio, ")
    sql:add("tom_end_cep, ")
    sql:add("tom_cid_uf, ")
    sql:add("cte_carac_adic_transp AS xCaracAd, ")
    sql:add("cte_carac_adic_servico AS xCaracSer, ")
    sql:add("cte_emissor AS xEmi, ")
    sql:add("cid_origem_sigla AS xOrig, ")
    sql:add("cid_passagem_sigla AS xPass, ")
    sql:add("cid_destino_sigla AS xDest, ")
    sql:add("cte_tp_data_entrega AS tpPer, ")
    sql:add("cte_data_programada AS dProg, ")
    sql:add("cte_data_inicial AS dIni, ")
    sql:add("cte_data_final AS dFim, ")
    sql:add("cte_tp_hora_entrega AS tpHor, ")
    sql:add("cte_hora_programada AS hProg, ")
    sql:add("cte_hora_inicial AS hIni, ")
    sql:add("cte_hora_final AS hFim, ")
    sql:add("cte_obs_gerais AS xObs, ")
    sql:add("clie_remetente_id, ")
    sql:add("rem_razao_social, ")
    sql:add("rem_nome_fantasia, ")
    sql:add("rem_cnpj, ")
    sql:add("rem_ie, ")
    sql:add("rem_cpf, ")
    sql:add("rem_fone, ")
    sql:add("rem_end_logradouro, ")
    sql:add("rem_end_numero, ")
    sql:add("rem_end_complemento, ")
    sql:add("rem_end_bairro, ")
    sql:add("rem_cid_codigo_municipio, ")
    sql:add("rem_cid_municipio, ")
    sql:add("rem_end_cep, ")
    sql:add("rem_cid_uf, ")
    sql:add("rem_icms, ")
    sql:add("clie_destinatario_id, ")
    sql:add("des_razao_social, ")
    sql:add("des_nome_fantasia, ")
    sql:add("des_cnpj, ")
    sql:add("des_ie, ")
    sql:add("des_cpf, ")
    sql:add("des_fone, ")
    sql:add("des_end_logradouro, ")
    sql:add("des_end_numero, ")
    sql:add("des_end_complemento, ")
    sql:add("des_end_bairro, ")
    sql:add("des_cid_codigo_municipio, ")
    sql:add("des_cid_municipio, ")
    sql:add("des_end_cep, ")
    sql:add("des_cid_uf, ")
    sql:add("des_icms, ")
    sql:add("clie_expedidor_id, ")
    sql:add("exp_razao_social, ")
    sql:add("exp_nome_fantasia, ")
    sql:add("exp_cnpj, ")
    sql:add("exp_ie, ")
    sql:add("exp_cpf, ")
    sql:add("exp_fone, ")
    sql:add("exp_end_logradouro, ")
    sql:add("exp_end_numero, ")
    sql:add("exp_end_complemento, ")
    sql:add("exp_end_bairro, ")
    sql:add("exp_cid_codigo_municipio, ")
    sql:add("exp_cid_municipio, ")
    sql:add("exp_end_cep, ")
    sql:add("exp_cid_uf, ")
    sql:add("exp_icms, ")
    sql:add("clie_recebedor_id, ")
    sql:add("rec_razao_social, ")
    sql:add("rec_nome_fantasia, ")
    sql:add("rec_cnpj, ")
    sql:add("rec_ie, ")
    sql:add("rec_cpf, ")
    sql:add("rec_fone, ")
    sql:add("rec_end_logradouro, ")
    sql:add("rec_end_numero, ")
    sql:add("rec_end_complemento, ")
    sql:add("rec_end_bairro, ")
    sql:add("rec_cid_codigo_municipio, ")
    sql:add("rec_cid_municipio, ")
    sql:add("rec_end_cep, ")
    sql:add("rec_cid_uf, ")
    sql:add("rec_icms, ")
    sql:add("cte_valor_total AS vTPrest, ")
    sql:add("cte_valor_bc AS vBC, ")
    sql:add("cte_aliquota_icms AS pICMS, ")
    sql:add("cte_valor_icms AS vICMS, ")
    sql:add("cte_perc_reduc_bc AS pRedBC, ")
    sql:add("cte_valor_cred_outorgado AS vCred, ")
    sql:add("cte_codigo_sit_tributaria AS codigo_situacao_tributaria, ")
    sql:add("cte_valor_pis AS vPIS, ")
    sql:add("cte_valor_cofins AS vCOFINS, ")
    sql:add("cte_valor_icms + cte_valor_pis + cte_valor_cofins AS vTotTrib, ")
    sql:add("cte_info_fisco AS infAdFisco, ")
    sql:add("cte_valor_carga AS vCarga, ")
    sql:add("produto_predominante_nome AS proPred, ")
    sql:add("gt_id_codigo AS cTar, ")
    sql:add("cte_outras_carac_carga AS xOutCat, ")
    sql:add("cte_peso_bruto AS peso_bruto, ")
    sql:add("cte_peso_cubado AS peso_cubado, ")
    sql:add("cte_peso_bc AS peso_bc, ")
    sql:add("cte_cubagem_m3 AS cubagem_m3, ")
    sql:add("cte_qtde_volumes AS qtde_volumes, ")
    sql:add("cte_tipo_doc_anexo AS tipo_doc_anexo, ")
    sql:add("cte_operacional_master AS nOCA, ")
    sql:add("cte_data_entrega_prevista AS dPrevAereo, ")
    sql:add("cte_monitor_action AS monitor_action ")
    sql:add("FROM view_ctes ")

    if (appEmpresas:count == 1)
        // Apenas uma empresa emitente
        empresa := appEmpresas:empresas[1]
        sql:add("WHERE emp_id = " + empresa:id)
    else
        // Mais de uma empresa emitente
        sql:add("WHERE emp_id IN (")
        primeiro := true
        for each empresa in appEmpresas:empresas
            if !primeiro
                sql:add(",")
            endif
            sql:add(empresa:id)
            primeiro := false
        next
        sql:add(")")
    endif

    // Real em produção: Remover estes comentários em produção ----------------------------
    //sql:add(" AND cte_monitor_action IN ('SUBMIT','GETFILES','CANCEL') ")

    // Testes em homologação: Remover este comando abaixo ---------------------------------
    sql:add(" AND cte_id BETWEEN 44501 AND 44512 ")
    // Testes em homologação --------------------------------------------------------------

    sql:add("ORDER BY cte_monitor_action, emp_id, cte_numero")

    ::ctes := {}
    ::ok := false
    dbCTes := TQuery():new(sql:value)

    if dbCTes:executed
        do while !dbCTes:db:Eof()
            hRow := convertFieldsDb(dbCTes:db:GetRow())
            AAdd(::ctes, TConhecimento():new(hRow))
            dbCTes:db:Skip()
        enddo
    endif

    ::ok := !(hmg_len(::ctes) == 0)
    dbCTes:Destroy()

return self

method count() class TDbConhecimentos
return hmg_len(::ctes)