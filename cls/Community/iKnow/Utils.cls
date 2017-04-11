Include %IKPublic

Class Community.iKnow.Utils
{

/// BLFileLocation - указывает на файл с черным списком
Parameter BLFileLocation As STRING = "C:\InterSystems\iKnow\BLs.txt";

/// BLFileLocation - указывает на файл с Sets
Parameter SetsFileLocation As STRING = "C:\InterSystems\iKnow\Sets.txt";

Parameter DomainName As STRING = "community";

Parameter BlackLists As STRING = "BLcommunity";

/// Для установки выполнить команду "do ##class(Community.iKnow.Utils).setup()"
ClassMethod setup() As %Status
{
	do ..CreateDomainIfNotExists(..#DomainName)
	do ##class(%iKnow.Domain).GetOrCreateId(..#DomainName)
	do ..AddSetsFromFile()
	do ..CreateBlackLists()
	return $$$OK
}

/// Для удаления выполнить команду "do ##class(Community.iKnow.Utils).remove()"
ClassMethod remove() As %Status
{
	k ^CommunityiKnowSets
	do ..DeleteBlackLists()
	do ..DeleteDomain(..#DomainName)
	return $$$OK
}

/// Удаление домена со всеми данными
/// domName - имя удаляемого домена
ClassMethod DeleteDomain(domName As %String = {..#DomainName}) As %Status
{
	if (##class(%iKnow.Domain).Exists(domName)) {
		set domain  = ##class(%iKnow.Domain).Open(domName)
		set domainId = domain.Id
		set tSC = ##class(%iKnow.Domain).DeleteId(domainId)	
		
		if (tSC = $$$OK) {
			write "Domain ", domName, " deleted successfully.", !
			return $$$OK
		}
		else {
			write "Error: failed to delete domain ", domName, !
			return $$$ERROR()
		}
	}
	else {
		write "Domain ", domName, " doesn't exist", !
		return $$$ERROR()
	}
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

/// Создание нового домена
/// domName - имя создаваемого домена
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

/// Метод создаёт черные списки по файлу BLs.txt, 
/// содержит построчно перечисленные термины, "!" - в начале строки символ комментария
/// domName - имя домена, в котором проводится действие
/// BLName - имя формируемого в домене черного списка
ClassMethod CreateBlackLists(domName As %String = {..#DomainName}, BLName As %String = {..#BlackLists}) As %Integer
{
 
	if (##class(%iKnow.Domain).Exists(domName)) {
		set domainId = ##class(%iKnow.Domain).GetOrCreateId(domName)
	} else {
		write "Error: domain " + domName + " not found"
		return $$$ERROR()
	}
	
	set blackListId = ##class(%iKnow.Utils.MaintenanceAPI).CreateBlackList(domainId, BLName)
	
	set stream = ##class(%Stream.FileCharacter).%New()
	set sc = stream.LinkToFile(..#BLFileLocation)
	
	while 'stream.AtEnd {		
		set line = stream.ReadLine()		
		set sc = ##class(%iKnow.Utils.MaintenanceAPI).AddStringToBlackList(domainId, blackListId, line)
		write "   line: ",line," added to black list",!
	}

	return blackListId
}

ClassMethod AddSetsFromFile(FileName As %String = {..#SetsFileLocation}) As %Status
{
	set stream = ##class(%Stream.FileCharacter).%New()
	set sc = stream.LinkToFile(FileName)
	
	while 'stream.AtEnd {		
		set line = stream.ReadLine()		
		set ^CommunityiKnowSets($p(line,",",1)) = $p(line,",",2)
		write "   line: ",line," added",!
	}
}

/// Метод удаляет черный список
/// domName - имя домена, в котором проводится действие
/// BLName - имя удаляемого в домене черного списка
ClassMethod DeleteBlackLists(domName As %String = {..#DomainName}, BLName As %String = {..#BlackLists}) As %Status
{
	if (##class(%iKnow.Domain).Exists(domName)) {
		set domainId = ##class(%iKnow.Domain).GetOrCreateId(domName)
	} else {
		write "Error: domain " + domName + " not found"
		return $$$ERROR()
	}
	
	set blackListId = ##class(%iKnow.Utils.MaintenanceAPI).GetBlackListId(domainId, BLName)
	set sc = ##class(%iKnow.Utils.MaintenanceAPI).DropBlackList(domainId, blackListId)
	
	if (sc=$$$OK)
	{	
		write "   black list deleted",!}
	else 
	{
		write "Error deleting black list",!
		write sc,!
	}
	
	return $$$OK
}

/// Метод обновляет или создаёт черные списки по файлу BlackList.txt, 
/// содержит построчно перечисленные термины, "!" - в начале строки символ комментария
/// domName - имя домена, в котором проводится действие
/// BLName - имя формируемого в домене черного списка
ClassMethod UpdateBlackLists(domName As %String = {..#DomainName}, BLName As %String = {..#BlackLists}) As %Status
{
	
	if (##class(%iKnow.Domain).Exists(domName)) {
		set domainId = ##class(%iKnow.Domain).GetOrCreateId(domName)
	} else {
		write "Error: domain " + domName + " not found"
		return $$$ERROR()
	}
	
	set sc = ..DeleteBlackLists(domName, BLName)
	if (sc = $$$OK)
	{
		write "BlackList ",BLName, " deleted",!	
	}
	
	set sc = ..CreateBlackLists(domName, BLName)
	if (sc = $$$OK)
	{
		write "BlackList ",BLName, " created",!	
	}	

	return $$$OK
}

/// Функция для добавления Set
ClassMethod AddSet(Concept As %String, Set As %String) As %Status
{
	set ^CommunityiKnowSets(Concept) = Set
	return $$$OK
}

}

