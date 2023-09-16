#include "hmg.ch"
#include <hbclass.ch>

class TDbEmpresas
    data empresas
    data ok
    method new() constructor
    method count() setget
    method getEmpresa(id)
end class

method new() class TDbEmpresas
    local empresa, nuvemFiscal
    local hRow, dbEmpresas, sql := TSQLString():new()

    sql:setValue("SELECT emp_id AS id, ")
    sql:add("CONCAT(emp_razao_social, '  (', emp_sigla_cia, IF(ISNULL(cid_sigla),'', CONCAT('-',cid_sigla)), ')') AS xNome, ")
    sql:add("emp_nome_fantasia AS xFant, ")
    sql:add("emp_cnpj AS CNPJ, ")
    sql:add("emp_inscricao_estadual AS IE, ")
    sql:add("emp_inscricao_municipal AS IM, ")
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
    sql:add("IF(emp_dacte_layout='RETRATO', '1', '2') AS tpImp, ")
    sql:add("nuvemfiscal_client_id, ")
    sql:add("nuvemfiscal_client_secret, ")
    sql:add("nuvemfiscal_cadastrar, ")
    sql:add("nuvemfiscal_alterar ")
    sql:add("FROM view_empresas ")
    sql:add("WHERE emp_ativa = 1 AND emp_tipo_emitente = 'CTE' AND emp_ambiente_sefaz IN (1,2) ")
    sql:add(" AND CONCAT(nuvemfiscal_client_id, nuvemfiscal_client_secret) IS NOT NULL ")
    sql:add("ORDER BY emp_id")

    ::empresas := {}
    ::ok := false
    dbEmpresas := TQuery():new(sql:value)

    if dbEmpresas:executed
        do while !dbEmpresas:db:Eof()
            hRow := convertFieldsDb(dbEmpresas:db:GetRow())
            empresa := TEmpresa():new(hRow)
            AAdd(::empresas, empresa)
            // Verifica se a empresa precisa ser cadastrada ou alterada na Nuvem Fiscal
            if empresa:nuvemfiscal_cadastrar
                nuvemFiscal := TApiNfEmpresas():new()
                if nuvemFiscal:Cadastrar(empresa)
                    // Se cadastrou, verifica se retornou campos diferentes e atualiza bd
                    consoleLog({"Empresa cadastrada | Campos retornados", hb_eol(), nuvemFiscal:responseBody})
                else
                    // Pega o motivo por não cadastrar
                endif
            elseif empresa:nuvemfiscal_alterar
                nuvemFiscal := TApiNfEmpresas():new()
                nuvemFiscal:Alterar(empresa)
            endif
            dbEmpresas:db:Skip()
        enddo
    endif

    ::ok := !(hmg_len(::empresas) == 0)
    dbEmpresas:Destroy()

return self

method count() class TDbEmpresas
return hmg_len(::empresas)

method getEmpresa(id) class TDbEmpresas
    local pos := hb_AScan(::empresas, {|oEmp| oEmp:FieldGet("id") == id})
    if (pos == 0)
        return nil
    endif
return ::empresas[pos]
