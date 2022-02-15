# DataEntitlement::Url is a metatype that supports both single and multiple urls
#
# @summary DataEntitlement::Url is a metatype that supports both single and multiple urls
type DataEntitlement::Url = Variant[Array[Stdlib::HTTPUrl], Stdlib::HTTPUrl]
