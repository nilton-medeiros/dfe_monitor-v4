#include "hmg.ch"
#include "hbclass.ch"

class TEmpresa

    data id readonly
    data xNome readonly
    data xFant readonly
    data CNPJ readonly
    data IE readonly
    data xLgr readonly
    data nro readonly
    data xCpl readonly
    data xBairro readonly
    data cUF readonly
    data xMunEnv readonly
    data cMunEnv readonly
    data UF readonly
    data CEP readonly
    data fone readonly
    data versao_xml readonly
    data tpAmb readonly
    data modal readonly
    data RNTRC readonly
    data utc readonly
    data remote_file_path readonly
    data email readonly
    data seguradora readonly
    data apolice readonly
    data CRT readonly
    data tpImp readonly

    method new(empresa) constructor

end class

method new(empresa) class TEmpresa

    ::id := empresa['id']
    ::xNome := empresa['xNome']
    ::xFant := empresa['xFant']
    ::CNPJ := empresa['CNPJ']
    ::IE := empresa['IE']
    ::xLgr := empresa['xLgr']
    ::nro := empresa['nro']
    ::xCpl := empresa['xCpl']
    ::xBairro := empresa['xBairro']
    ::cUF := empresa['cUF']
    ::xMunEnv := empresa['xMunEnv']
    ::cMunEnv := empresa['cMunEnv']
    ::UF := empresa['UF']
    ::CEP := empresa['CEP']
    ::fone := empresa['fone']
    ::versao_xml := empresa['versao_xml']
    ::tpAmb := empresa['tpAmb']
    ::modal := empresa['modal']
    ::RNTRC := empresa['RNTRC']
    ::utc := empresa['utc']
    ::remote_file_path := empresa['remote_file_path']
    ::email := empresa['email']
    ::seguradora := empresa['seguradora']
    ::apolice := empresa['apolice']
    ::CRT := empresa['CRT']
    ::tpImp := empresa['tpImp']

return self
