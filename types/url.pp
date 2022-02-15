# Data_entitlement::Url is a metatype that supports both single and multiple urls
#
# @summary Data_entitlement::Url is a metatype that supports both single and multiple urls
type Data_entitlement::Url = Variant[Array[Stdlib::HTTPUrl], Stdlib::HTTPUrl]
