
str = JSON.json(Dict(
    "observations" => ["/home/abarth/projects/Julia/divand-example-data/Provencal/WOD-Salinity.nc"],
    "bbox" => encodebbox([-10,30,50,45]),
    "depth" => encodelist([0,20]),
    "len" => encodelist([100e3,100e3]),
    "epsilon2" => 1.,
    "resolution" => encodelist([1,1]),
    "years" => encodelist(1993,1993),
    "dataset" => "GEBCO"
))

data = JSON.parse(str)
if haskey(data,"bbox")
    data["bbox"] = decodebbox(data["bbox"])
end

for key in ["resolution","depth","len","years"]
    if haskey(data,key)
        data[key] = decodelist(data[key])
    end
end

for key in ["epsilon2"]
    if haskey(data,key)
        data[key] = parse(Float64,data[key])
    end
end

minlon,minlat,maxlon,maxlat = data["bbox"]
Δlon,Δlat = data["resolution"]

lonr = minlon:Δlon:maxlon
latr = minlat:Δlat:maxlat

bathname = "/home/ulg/gher/abarth/Julia/divand-example-data/Global/Bathymetry/gebco_30sec_16.nc"
bathisglobal = true

#mask,(pm,pn),(xi,yi) = divand.domain(bathname,bathisglobal,lonr,latr)




# 
varname = "Salinity"
filename = "WOD-Salinity.nc"

obsname = data["observations"]
epsilon2 = data["epsilon2"]

value,lon,lat,depth,time,ids = divand.loadobs(Float64,obsname,"Salinity")


sz = (length(lonr),length(latr),length(depthr))

lenx = fill(data["len"][1],sz)
leny = fill(data["len"][2],sz)
lenz = [10+depthr[k]/15 for i = 1:sz[1], j = 1:sz[2], k = 1:sz[3]]

@show mean(lenz)
years = data["years"]

year_window = 10

# winter: January-March    1,2,3
# spring: April-June       4,5,6
# summer: July-September   7,8,9
# autumn: October-December 10,11,12

monthlists = [
    [1,2,3],
    [4,5,6],
    [7,8,9],
    [10,11,12]
];


TS = divand.TimeSelectorYW(years,year_window,monthlists)

varname = "Salinity"

# File name based on the variable (but all spaces are replaced by _)
filename = "Water_body_$(replace(varname,' ','_')).4Danl.nc"


metadata = OrderedDict(
    # Name of the project (SeaDataCloud, SeaDataNet, EMODNET-Chemistry, ...)
    "project" => "SeaDataCloud",

    # URN code for the institution EDMO registry,
    # e.g. SDN:EDMO::1579
    "institution_urn" => "SDN:EDMO::1579",

    # Production group
    "production" => "Diva group. E-mails: a.barth@ulg.ac.be, swatelet@ulg.ac.be",

    # Name and emails from authors
    "Author_e-mail" => ["Your Name1 <name1@example.com>", "Other Name <name2@example.com>"],

    # Source of the observation
    "source" => "observational data from SeaDataNet/EMODNet Chemistry Data Network",

    # Additional comment
    "comment" => "...",

    # SeaDataNet Vocabulary P35 URN
    # http://seadatanet.maris2.nl/v_bodc_vocab_v2/search.asp?lib=p35
    # example: SDN:P35::WATERTEMP
    "parameter_keyword_urn" => "SDN:P35::EPC00001",

    # List of SeaDataNet Parameter Discovery Vocabulary P02 URNs
    # http://seadatanet.maris2.nl/v_bodc_vocab_v2/search.asp?lib=p02
    # example: ["SDN:P02::TEMP"]
    "search_keywords_urn" => ["SDN:P02::PSAL"],

    # List of SeaDataNet Vocabulary C19 area URNs
    # SeaVoX salt and fresh water body gazetteer (C19)
    # http://seadatanet.maris2.nl/v_bodc_vocab_v2/search.asp?lib=C19
    # example: ["SDN:C19::3_1"]
    "area_keywords_urn" => ["SDN:C19::3_3"],

    "product_version" => "1.0",

    # NetCDF CF standard name
    # http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
    # example "standard_name" = "sea_water_temperature",
    "netcdf_standard_name" => "sea_water_salinity",

    "netcdf_long_name" => "sea water salinity",

    "netcdf_units" => "1e-3",

    # Abstract for the product
    "abstract" => "...",

    # This option provides a place to acknowledge various types of support for the
    # project that produced the data
    "acknowledgment" => "...",

    # Digital Object Identifier of the data product
    "doi" => "...")


# edit the bathymetry
mask,(pm,pn,po),(xi,yi,zi) = divand.domain(bathname,bathisglobal,lonr,latr,depthr)
mask[3,3,1] = false

ncglobalattrib,ncvarattrib = divand.SDNMetadata(metadata,filename,varname,lonr,latr)

if isfile(filename)
   rm(filename) # delete the previous analysis
end

divand.diva3d((lonr,latr,depthr,TS),
              (lon,lat,depth,time),
              value,epsilon2,
              (lenx,leny,lenz),
              filename,varname,
              bathname = bathname,
              bathisglobal = bathisglobal,
              ncvarattrib = ncvarattrib,
              ncglobalattrib = ncglobalattrib,
              mask = mask,
       )

divand.saveobs(filename,(lon,lat,depth,time),ids)




