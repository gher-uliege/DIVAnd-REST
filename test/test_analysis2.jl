import JSON
import DIVAnd
using DataStructures

data0 = OrderedDict(
    "observations" => "sampledata:WOD-Salinity",
    "varname" => "Salinity",
    "bbox" => [3.,42.,12.,44.],  # minlon,minlat,maxlon,maxlat
    "depth" => [0,20,50],
    "len" => [100e3,100e3],
    "epsilon2" => 1.,
    "resolution" => [.5,.5],
    "years" => [1993,1993],
    "monthlist" => [
        [1,2,3],
        [4,5,6],
        [7,8,9],
        [10,11,12]
    ],

    "bathymetry" => "sampledata:gebco_30sec_16",

    # Name of the project (SeaDataCloud, SeaDataNet, EMODNET-Chemistry, ...)
    "metadata_project" => "SeaDataCloud",

    # URN code for the institution EDMO registry,
    # e.g. SDN:EDMO::1579
    "metadata_institution_urn" => "SDN:EDMO::1579",

    # Production group
    "metadata_production" => "Diva group. E-mails: a.barth@ulg.ac.be, swatelet@ulg.ac.be",

    # Name and emails from authors
    "metadata_Author_e-mail" => ["Your Name1 <name1@example.com>", "Other Name <name2@example.com>"],

    # Source of the observation
    "metadata_source" => "observational data from SeaDataNet/EMODNet Chemistry Data Network",

    # Additional comment
    "metadata_comment" => "...",

    # SeaDataNet Vocabulary P35 URN
    # http://seadatanet.maris2.nl/v_bodc_vocab_v2/search.asp?lib=p35
        # example: SDN:P35::WATERTEMP
    "metadata_parameter_keyword_urn" => "SDN:P35::EPC00001",

    # List of SeaDataNet Parameter Discovery Vocabulary P02 URNs
    # http://seadatanet.maris2.nl/v_bodc_vocab_v2/search.asp?lib=p02
    # example: ["SDN:P02::TEMP"]
    "metadata_search_keywords_urn" => ["SDN:P02::PSAL"],

    # List of SeaDataNet Vocabulary C19 area URNs
    # SeaVoX salt and fresh water body gazetteer (C19)
    # http://seadatanet.maris2.nl/v_bodc_vocab_v2/search.asp?lib=C19
    # example: ["SDN:C19::3_1"]
    "metadata_area_keywords_urn" => ["SDN:C19::3_3"],

    "metadata_product_version" => "1.0",

    # NetCDF CF standard name
    # http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
    # example "standard_name" = "sea_water_temperature",
    "metadata_netcdf_standard_name" => "sea_water_salinity",

    "metadata_netcdf_long_name" => "sea water salinity",

    "metadata_netcdf_units" => "1e-3",

    # Abstract for the product
    "metadata_abstract" => "...",

    # This option provides a place to acknowledge various types of support for the
    # project that produced the data
    "metadata_acknowledgment" => "...",

    # Digital Object Identifier of the data product
    "metadata_doi" => "..."
)


str = JSON.json(data0)


open(replace(@__FILE__,r".jl$" => ".json"),"w") do f
    JSON.print(f,data0, 3)
end

# use dicttype=DataStructures.OrderedDict to maintain the order
data = JSON.parse(str; dicttype=DataStructures.OrderedDict)



# File name based on the variable (but all spaces are replaced by _)
filename = "Water_body_$(replace(data["varname"],' ' => '_')).4Danl.nc"


analysis_wrapper(data,filename)
