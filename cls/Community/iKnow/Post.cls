Include %IKPublic

Class Community.iKnow.Post
{

ClassMethod GetConceptsByID(ID As %String) As %String
{

	set domName = "Post"
	do ..CreateDomainIfNotExists(domName)
	set domId  = ##class(%iKnow.Domain).GetOrCreateId(domName)

	set lister = ##class(%iKnow.Source.SQL.Lister).%New(domId)
	set loader = ##class(%iKnow.Source.Loader).%New(domId)
	
	do ##class(%iKnow.Queries.MetadataAPI).AddField(domId,"ID",,"NUMBER")
	
	
	set myquery = "SELECT ID, Text FROM Community.Post where ID = "_ID
	
	set meta = $lb("ID")
	set data = $lb("Text")
	set group = "ID"
	set id = "ID"
	set tSC = lister.AddListToBatch(myquery, id, group, data, meta)
	do loader.ProcessBatch()
	
	set count = ##class(%iKnow.Queries.EntityAPI).GetCountByDomain(domId)
	set tSC = ##class(%iKnow.Queries.EntityAPI).GetTop(.tResult, domId, 1, count)
	
	set tSC = ##class(%iKnow.Queries.MetadataAPI).RemoveField(domId, "ID")
	set tSC = ##class(%iKnow.Domain).%OpenId(domId).DropData(1, 1, 1, 1, 1)

	set result =""
	for i=1:1:count
	{
		if $DATA(tResult(i))
		{ 
			set result = result_","_$list(tResult(i),2)
		}else{
			return result
		}
	}

	return result
}

ClassMethod CreateDomainIfNotExists(domName As %String) As %Status
{
	if '(##class(%iKnow.Domain).Exists(domName)) 
	{
		write "Domain " _ domName _ " does not exist.", !
	
		write "Creating new domain: " _ domName, !
				
		#dim status As %Status = ..CreateDomain(domName)
			
		if (status = $$$OK) 
		{
			write "New domain " _ domName _ " was created successfully.", !	
		}
		else 
		{
			return status
		}	
	}
	return 0
}


ClassMethod CreateDomain(domName As %String) As %iKnow.Domain
{
	if (##class(%iKnow.Domain).Exists(domName))
	{
		#dim domain As %iKnow.Domain = ##class(%iKnow.Domain).Open(domName)
		write "   open domain ", domName, " ", !
	}
	else
	{
		set domain = ##class(%iKnow.Domain).%New(domName)
		do domain.%Save()
		do domain.SetParameter($$$IKPSTEMMING, 1)	
		do domain.%Save()
		
		write "   domain ", domName, " created!", !
	}
	return domain
}

}

