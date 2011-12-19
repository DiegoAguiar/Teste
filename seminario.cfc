<cfcomponent displayname="Seminario">
	<cfset DSN="ORACLE_SESC_SEMINARIO">
	<cffunction name="verificaLen" access="private" returntype="boolean" hint="Valida o tamanho do campo passado com o tamanho passado">
    	<cfargument name="campo" type="any" required="yes" hint="Valor que será verificado">
        <cfargument name="tamanho" type="numeric" required="yes" hint="Tamanho máximo do campo">
        <cfif Len(arguments.campo) lte arguments.tamanho>
        	<cfset sOut=true>
        <cfelse>
        	<cfset sOut=false>
        </cfif>
        <cfreturn sOut>
    </cffunction>
    
    <cffunction name="retiraComa" access="private" returntype="string" hint="Retira os separadores dos campos">
    	<cfargument name="campo" type="any" required="yes" hint="Valor que será retirado os separadores">
        <cfargument name="separadores" type="string" required="yes" hint="Lista de separadores a ser retirados formato regex. exp: [.,'/<]">
        <cfset sOut=''>
       	<cfset sOut=REReplace(arguments.campo,arguments.separadores,'','all')>
        <cfreturn sOut>
    </cffunction>
    
	<cffunction name="constructErrorMessage" access="private" returntype="string" hint="Cria um XML padrão para retorno em caso de erro">
		<cfargument name="error" required="yes">
		<cfset xmlErro= XMLParse('<?xml version="1.0" encoding="ISO-8859-1"?><RETORNO><MENSAGEM>'&error.message&'</MENSAGEM></RETORNO>')>
		<cfreturn xmlErro>
	</cffunction>
    
    <cffunction name="retiraTag" access="private" returntype="string" hint="Retira as tags sem fechamento das mensagens de erro">
		<cfargument name="xml" required="yes">
		
		<cfset xmlMsg=arguments.xml>
        <!---Verifica se o xml é o de uma mensagem de erro--->
        <cfif FindNoCase('<RETORNO><MENSAGEM>',arguments.xml)>
			<!---Calcula a posição aonde começa a mensagem de erro--->
            <cfset inicio=FindNoCase('<RETORNO><MENSAGEM>',arguments.xml)+19>
            <!---Calcula quantas posições existem na mensagem de erro--->
            <cfset total=FindNoCase('</MENSAGEM></RETORNO>',arguments.xml)-inicio>
            <!---Calcula a posição aonde termina a mensagem de erro--->
            <cfset fim=FindNoCase('</MENSAGEM></RETORNO>',arguments.xml)>
            <!---Retiras as aberturas e fechamentos de qualquer tag dentro da mensagem--->
            <cfset mensagem=Replace(Replace(Mid(arguments.xml,variables.inicio,variables.total),'<','','all'),'>','','all')>
            <!---Reescreve o xml com a mensagem formatada, colocando primeiro a string até o começo da mensagem--->
            <cfset xmlMsg=Mid(arguments.xml,1,variables.inicio-1)>
            <!---Reescreve o xml com a mensagem formatada, concatena a nova mensagem sem < e >--->
            <cfset xmlMsg=variables.xmlMsg&variables.mensagem>
            <!---Reescreve o xml com a mensagem formatada, coloca a parte final da string--->
            <cfset xmlMsg=variables.xmlMsg&Mid(arguments.xml,variables.fim,Len(arguments.xml))>
        </cfif>
		<cfreturn xmlMsg>
	</cffunction>
    
	<cffunction name="fncConsultaSeminario" access="remote" returntype="xml" hint="Lista os Seminários liberados para venda no período informado">
		<cfargument name="DT_STR_INI" type="string" required="yes">
		<cfargument name="DT_STR_FIM" type="string" required="yes">
        <cfargument name="UOR_CODIGO" type="numeric" required="yes">
        
        <cfif verificaLen(campo=arguments.DT_STR_INI,tamanho=10)
			 and verificaLen(campo=arguments.DT_STR_FIM,tamanho=10) 
			 and verificaLen(campo=arguments.UOR_CODIGO,tamanho=3)>
            
            <cftry>
            	<cfset dt_ini=retiraComa(campo=arguments.DT_STR_INI,separadores='[/]')>
                <cfset dt_fim=retiraComa(campo=arguments.DT_STR_FIM,separadores='[/]')>
                <cfstoredproc procedure="CGS_WEB_SERVICE.CONSULTA_SEMINARIO" datasource="#variables.DSN#">
                    <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="P_DT_STR_INI" value="#variables.dt_ini#">
                    <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="P_DT_STR_FIM" value="#variables.dt_fim#">
                    <cfif arguments.UOR_CODIGO eq 0><!---Se for 0, mostrar todas as UO's conforme doc--->
                    	<cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="P_UOR_CODIGO" null="yes">
                    <cfelse>
                    	<cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="P_UOR_CODIGO" value="#arguments.UOR_CODIGO#">
                    </cfif>
                    <cfprocparam type="out" cfsqltype="cf_sql_varchar" variable="XML_SEMINARIO">
                </cfstoredproc>
                <cfset XML_SEMINARIO=retiraTag(xml=XML_SEMINARIO)>
                <cfcatch type="any">
                	<cfdump var="#variables#"><cfabort>
                	<cfset XML_SEMINARIO = constructErrorMessage(error=cfcatch)>
                </cfcatch>
            </cftry>
		<cfelse>
        	<cfset erroLen.message='Argumentos com tamanho inválido'>
        	<cfset XML_SEMINARIO = constructErrorMessage(error=variables.erroLen)>
        </cfif>
		<cfreturn XML_SEMINARIO>
	</cffunction>
    
    <cffunction name="fncVerificaInscricao" access="remote" returntype="xml" hint="Esse serviço possibilita a consulta, recuperação e a continuidade do processo de inscrição de acordo com a etapa à qual a inscrição tenha sido interrompida.">
		<cfargument name="CGS_CODIGO" type="numeric" required="yes">
		<cfargument name="CLI_CODIGO" type="numeric" required="no" default="0">
        <cfargument name="CGI_CODIGO" type="numeric" required="no" default="0">
        <cfargument name="MEU_SESC_CODIGO" type="string" required="yes">
        
        <cfif verificaLen(campo=arguments.CGS_CODIGO,tamanho=6)
			 and verificaLen(campo=arguments.CLI_CODIGO,tamanho=6) 
			 and verificaLen(campo=arguments.CGI_CODIGO,tamanho=6)
			 and verificaLen(campo=arguments.MEU_SESC_CODIGO,tamanho=20)>
        	
        	<cftry>
                <cfstoredproc procedure="CGS_WEB_SERVICE.VERIFICA_INSCRICAO" datasource="#variables.DSN#">
                    <cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="P_CGS_CODIGO" value="#arguments.CGS_CODIGO#">
                    <cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="P_CLI_CODIGO" value="#arguments.CLI_CODIGO#">
                    <cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="P_CGI_CODIGO" value="#arguments.CGI_CODIGO#">
                    <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="P_MEU_SESC_CODIGO" value="#arguments.MEU_SESC_CODIGO#">
                    <cfprocparam type="out" cfsqltype="cf_sql_varchar" variable="XML_RETORNO">
                </cfstoredproc>
                <cfset XML_RETORNO=retiraTag(xml=XML_RETORNO)>
                <cfcatch type="any">
                	<cfset XML_RETORNO = constructErrorMessage(error=cfcatch)>
                </cfcatch>
            </cftry> 
        <cfelse>
        	<cfset erroLen.message='Argumento com tamanho inválido'>
        	<cfset XML_RETORNO = constructErrorMessage(error=variables.erroLen)>
        </cfif>
		<cfreturn XML_RETORNO>
	</cffunction>
    
    <cffunction name="fncGradeSeminario" access="remote" returntype="xml" hint="Esse serviço recupera a grade de atividades contendo as salas, disponibilidade, escolhas (caso seja de uma inscrição já existente).">
    	<cfargument name="CGS_CODIGO" type="numeric" required="yes">
		<cfargument name="CGI_CODIGO" type="numeric" required="no" default="0">
        <cfargument name="CGSS_TIPO_ATIVIDADE" type="string" required="yes">
        
        <cfif verificaLen(campo=arguments.CGS_CODIGO,tamanho=6)
			 and verificaLen(campo=arguments.CGI_CODIGO,tamanho=6) 
			 and verificaLen(campo=arguments.CGSS_TIPO_ATIVIDADE,tamanho=1)>
        
        	<cftry>
                <cfstoredproc procedure="CGS_WEB_SERVICE.GRADE_SEMINARIO" datasource="#variables.DSN#">
                    <cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="P_CGS_CODIGO" value="#arguments.CGS_CODIGO#">
                    <cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="P_CGI_CODIGO" value="#arguments.CGI_CODIGO#">
                    <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="P_CGSS_TIPO_ATIVIDADE" value="#arguments.CGSS_TIPO_ATIVIDADE#">
                    <cfprocparam type="out" cfsqltype="cf_sql_varchar" variable="XML_GRADE">
                </cfstoredproc>
                <cfset XML_GRADE=retiraTag(xml=XML_GRADE)>
                <cfcatch type="any">
                	<cfset XML_GRADE = constructErrorMessage(error=cfcatch)>
                </cfcatch>
            </cftry> 
        <cfelse>
        	<cfset erroLen.message='Argumento com tamanho inválido'>
        	<cfset XML_GRADE = constructErrorMessage(error=variables.erroLen)>
        </cfif>
		<cfreturn XML_GRADE>
    </cffunction>
    
    <cffunction name="fncGravaInscricao" access="remote" returntype="xml" hint="Esse serviço recupera a grade de atividades contendo as salas, disponibilidade, escolhas (caso seja de uma inscrição já existente).">
    	<cfargument name="XML_GRADE" type="string" required="yes">
        <cftry>
            <cfstoredproc procedure="CGS_WEB_SERVICE.GRAVA_INSCRICAO" datasource="#variables.DSN#">
                <cfprocparam type="inout" cfsqltype="cf_sql_varchar" variable="XML_GRADE" value="#arguments.XML_GRADE#">
            </cfstoredproc>
            <cfset XML_GRADE=retiraTag(xml=XML_GRADE)>
            <cfcatch type="any">
                <cfset XML_GRADE = constructErrorMessage(error=cfcatch)>
            </cfcatch>
        </cftry> 
		<cfreturn XML_GRADE>
    </cffunction>
    
    <cffunction name="fncPesquisaCliente" access="remote" returntype="xml" hint="A partir de um conjunto mínimo de informações este método pesquisa as informações existentes no cadastro de cliente ou no banco de dados de matriculados.">
    	<cfargument name="XML_ENTRADA" type="string" required="yes">
		<cftry>
            <cfstoredproc procedure="CGS_WEB_SERVICE.PESQUISA_CLIENTE" datasource="#variables.DSN#">
                <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="XML_ENTRADA" value="#arguments.XML_ENTRADA#">
                <cfprocparam type="out" cfsqltype="cf_sql_varchar" variable="XML_CLIENTE">
            </cfstoredproc>
            <cfset XML_CLIENTE=retiraTag(xml=XML_CLIENTE)>
            <cfcatch type="any">
            	<cfset XML_CLIENTE = constructErrorMessage(error=cfcatch)>
            </cfcatch>
        </cftry>
        <cfreturn XML_CLIENTE>
    </cffunction>
    
    <cffunction name="fncCadastraCliente" access="remote" returntype="xml" hint="Grava as informações do Cliente, criando ou atualizando as informações do mesmo na base de clientes do SESC.Atualiza a ficha de Inscrição no Seminário de acordo com as informações e faz a vinculação entre a inscrição e o cadastro de cliente.">
    	<cfargument name="XML_ENTRADA" type="string" required="yes">
		<cftry>
            <cfstoredproc procedure="CGS_WEB_SERVICE.CADASTRA_CLIENTE" datasource="#variables.DSN#">
                <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="XML_ENTRADA" value="#arguments.XML_ENTRADA#">
                <cfprocparam type="out" cfsqltype="cf_sql_varchar" variable="XML_RETORNO">
            </cfstoredproc>
            <cfset XML_RETORNO=retiraTag(xml=XML_RETORNO)>
            <cfcatch type="any">
            	<cfset XML_RETORNO = constructErrorMessage(error=cfcatch)>
            </cfcatch>
        </cftry>
        <cfreturn XML_RETORNO>
    </cffunction>
    
    <cffunction name="fncSelecionaPagamento" access="remote" returntype="xml" hint="A partir da inscrição válida, retorna o valor líquido, os meios de pagamento disponíveis (ex. Cartão de Crédito, Cartão de Débito, Boleto Bancário, etc), bandeiras e quantidade de parcelas possíveis (caso haja a opção de parcelamento).">
    	<cfargument name="XML_ENTRADA" type="string" required="yes">
		<cftry>
            <cfstoredproc procedure="CGS_WEB_SERVICE.SELECIONA_PAGAMENTO" datasource="#variables.DSN#">
                <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="XML_ENTRADA" value="#arguments.XML_ENTRADA#">
                <cfprocparam type="out" cfsqltype="cf_sql_varchar" variable="XML_RETORNO">
            </cfstoredproc>
            <cfset XML_RETORNO=retiraTag(xml=XML_RETORNO)>
            <cfcatch type="any">
            	<cfset XML_RETORNO = constructErrorMessage(error=cfcatch)>
            </cfcatch>
        </cftry>
        <cfreturn XML_RETORNO>
    </cffunction>
    
    <cffunction name="fncEfetuaPagamento" access="remote" returntype="xml" hint="Atualiza a Ficha de inscrição com a opção de pagamento escolhida e chama o método IniciaPagamento do SESCPAG.">
    	<cfargument name="XML_ENTRADA" type="string" required="yes">
		<cftry>
            <cfstoredproc procedure="CGS_WEB_SERVICE.SELECIONA_PAGAMENTO" datasource="#variables.DSN#">
                <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="XML_ENTRADA" value="#arguments.XML_ENTRADA#">
                <cfprocparam type="out" cfsqltype="cf_sql_varchar" variable="XML_RETORNO">
            </cfstoredproc>
            <cfset XML_RETORNO=retiraTag(xml=XML_RETORNO)>
            <cfcatch type="any">
            	<cfset XML_RETORNO = constructErrorMessage(error=cfcatch)>
            </cfcatch>
        </cftry>
        <cfreturn XML_RETORNO>
    </cffunction>
    
    <cffunction name="fncDocTipo" access="remote" returntype="xml" hint="Lista a relação de tipo de documentos">
    	<cftry>
            <cfquery datasource="#variables.DSN#" name="DocTipo">
                select CGS_WEB_SERVICE.LISTA_DOC_TIPO from dual
            </cfquery>
            <cfset doc=DocTipo.lista_doc_tipo>
            <cfcatch type="any">
            	<cfset doc = constructErrorMessage(error=cfcatch)>
            </cfcatch>
        </cftry>
        <cfreturn doc>
    </cffunction>
    
    <cffunction name="fncDocEmissor" access="remote" returntype="xml" hint="Lista a relação de Órgão emissor do documento">
    	<cftry>
            <cfquery datasource="#variables.DSN#" name="DocEmissor">
                select CGS_WEB_SERVICE.LISTA_DOC_EMISSOR from dual
            </cfquery>
            <cfset emissordoc=DocEmissor.lista_doc_emissor>
            <cfcatch type="any">
            	<cfset emissordoc = constructErrorMessage(error=cfcatch)>
            </cfcatch>
        </cftry>
        <cfreturn emissordoc>
    </cffunction>
    
    <cffunction name="fncEstadoCivil" access="remote" returntype="xml" hint="Lista a relação de opções disponíveis ao preenchimento do Estado Civil do Cliente">
    	<cftry>
            <cfquery datasource="#variables.DSN#" name="EstadoCivil">
                select CGS_WEB_SERVICE.LISTA_ESTADO_CIVIL from dual
            </cfquery>
            <cfset estadocivil=EstadoCivil.lista_estado_civil>
            <cfcatch type="any">
            	<cfset estadocivil = constructErrorMessage(error=cfcatch)>
            </cfcatch>
        </cftry>
        <cfreturn estadocivil>
    </cffunction>
    
    <cffunction name="fncCatFuncional" access="remote" returntype="xml" hint="Lista a relação de categorias funcionais necessárias ao cálculo do valor da inscrição">
    	<cftry>
            <cfquery datasource="#variables.DSN#" name="CatFuncional">
                select CGS_WEB_SERVICE.LISTA_CAT_FUNCIONAL from dual
            </cfquery>
            <cfset catfuncional=CatFuncional.lista_cat_funcional>
            <cfcatch type="any">
            	<cfset catfuncional = constructErrorMessage(error=cfcatch)>
            </cfcatch>
        </cftry>
        <cfreturn catfuncional>
    </cffunction>
    
</cfcomponent>