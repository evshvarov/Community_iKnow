Include %IKPublic

Class Community.iKnow.Answer
{

Parameter DomainName As STRING = "community";

Parameter BlackLists As STRING = "BLcommunity";

ClassMethod GetConceptsByID(ID As %String) As %String
{
	set domId  = ##class(%iKnow.Domain).GetOrCreateId(..#DomainName)

	set lister = ##class(%iKnow.Source.SQL.Lister).%New(domId)
	set loader = ##class(%iKnow.Source.Loader).%New(domId)
	
	do ##class(%iKnow.Queries.MetadataAPI).AddField(domId,"ID",,"NUMBER")
	
	set myquery = "SELECT ID, Text FROM Community.Comment where ID = "_ID
	
	set meta = $lb("ID")
	set data = $lb("Text")
	set group = "ID"
	set id = "ID"
	
	set tSC = lister.AddListToBatch(myquery, id, group, data, meta)
	do loader.ProcessBatch()
	
	set blackListId = ##class(%iKnow.Utils.MaintenanceAPI).GetBlackListId(domId, ..#BlackLists)
	
	set count = ##class(%iKnow.Queries.EntityAPI).GetCountByDomain(domId)
	set tSC = ##class(%iKnow.Queries.EntityAPI).GetTop(.tResult, domId, 1, count, "", $$$FILTERONLY, $$$SORTBYDOMAINDEFAULT, $$$ENTTYPECONCEPT, 0, blackListId)

	
	set tSC = ##class(%iKnow.Domain).%OpenId(domId).DropData(1, 1, 1, 0, 1)

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

}

