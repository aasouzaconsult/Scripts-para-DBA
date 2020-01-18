use TopManager

Declare @CdObj  int
,	@Data smalldatetime

Set @CdObj  = 5754
Set @Data = getdate()

Select  Top 1
	Cpo.CdObj
,	Frn.NmFrn
,	Cpd.NrCpd
,	Cpd.DtCpdCon
From TbCpo Cpo (nolock)
join TbCpd Cpd (nolock) on Cpd.CdCpd = Cpo.CdCpd
join TbFrn Frn (nolock) on Frn.CdFrn = Cpd.CdFrn
Where Cpo.CdObj = @CdObj
and  Cpd.FlCpdCpt = 1
and  Cpd.DtCpdCon <= @Data
Order by
	Cpd.DtCpdCon Desc
,	Cpd.CdCpd
,	Cpo.CdCpo
