# Data_Entitlement::Url is a metatype that supports both single and multiple urls
#
# @summary Data_Entitlement::Url is a metatype that supports both single and multiple urls
type Data_Entitlement::Url = Variant[Array[Stdlib::HTTPUrl], Stdlib::HTTPUrl]
