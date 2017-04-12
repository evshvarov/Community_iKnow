Class Community.iKnow.ObjectSource Extends %iKnow.Objects.Source
{

Property LocalReference As %String(MAXLEN = 1000);

Index LocalReferanceIndex On (DomainId, LocalReference) [ Unique ];

Storage iKnowStorage
{
<Type>%Library.CacheSQLStorage</Type>
}

}

