#include "hmg.ch"
#include <hbclass.ch>

class TDbEmpresas
    data empresas
    data ok
    method new() constructor
    method count() setget
end class

method new() class TDbEmpresas
    local hRow, dbCompanies, sql := TSQLString():new()

    sql:setValue("SELECT emp_id AS id, ")
    sql:add("CONCAT(emp_razao_social, '  (', emp_sigla_cia, IF(ISNULL(cid_sigla),'', CONCAT('-',cid_sigla)), ')') AS xNome, ")
    sql:add("emp_nome_fantasia AS xFant, ")
    sql:add("emp_cnpj AS CNPJ, ")
    sql:add("emp_inscricao_estadual AS IE, ")
    sql:add("emp_logradouro AS xLgr, ")
    sql:add("emp_numero AS nro, ")
    sql:add("emp_complemento AS xCpl, ")
    sql:add("emp_bairro AS xBairro, ")
    sql:add("cid_codigo_uf AS cUF, ")
    sql:add("cid_municipio AS xMunEnv, ")
    sql:add("cid_codigo_municipio AS cMunEnv, ")
    sql:add("cid_uf AS UF, ")
    sql:add("emp_cep AS CEP, ")
    sql:add("emp_fone1 AS fone, ")
    sql:add("emp_versao_layout_xml AS versao_xml, ")
    sql:add("emp_ambiente_sefaz AS tpAmb, ")
    sql:add("emp_modal_codigo AS modal, ")
    sql:add("emp_RNTRC AS RNTRC, ")
    sql:add("utc, ")
    sql:add("remote_file_path, ")
    sql:add("emp_email_comercial AS email, ")
    sql:add("emp_seguradora AS seguradora, ")
    sql:add("emp_apolice AS apolice, ")
    sql:add("emp_simples_nacional AS CRT, ")
    sql:add("IF(emp_dacte_layout='RETRATO', '1', '2') AS tpImp ")
    sql:add("FROM view_empresas ")
    sql:add("WHERE emp_ativa = 1 AND emp_tipo_emitente = 'CTE' AND emp_ambiente_sefaz IN (1,2) ")
    sql:add("ORDER BY emp_id")

    ::empresas := {}
    ::ok := false
    dbCompanies := TQuery():new(sql:value)

    if dbCompanies:executed
        do while !dbCompanies:db:Eof()
            hRow := convertFieldsDb(dbCompanies:db:GetRow())
            AAdd(::empresas, TEmpresa():new(hRow))
            dbCompanies:db:Skip()
        enddo
    endif

    ::ok := !(hmg_len(::empresas) == 0)
    dbCompanies:Destroy()

return self

method count() class TDbEmpresas
return hmg_len(::empresas)