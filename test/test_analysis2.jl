import JSON
import divand
using DataStructures

str = JSON.json(OrderedDict(
    "observations" => "sampledata:WOD-Salinity",
    "varname" => "Salinity",
    "bbox" => [-3.,42.,12.,44.],  # minlon,minlat,maxlon,maxlat
    "depth" => [0,20],
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
    
    "metadata" => OrderedDict(
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
        "doi" => "..."
    )

))

datalist = Dict{String,String}(
    "WOD-Salinity" => "data/WOD-Salinity.nc",
    "gebco_30sec_16" => "data/gebco_30sec_16.nc"
)

function resolvedata(url)       
    if startswith(url,"sampledata:")
        return datalist[split(url,"data:")[2]]
    elseif (startswith(url,"http:") || startswith(url,"https:") ||
            startswith(url,"ftp:"))
        return download(url)
    else
        error("URI scheme is not allowed $(url)")
    end
end        


# use dicttype=DataStructures.OrderedDict to maintain the order
data = JSON.parse(str; dicttype=DataStructures.OrderedDict)

minlon,minlat,maxlon,maxlat = data["bbox"]
Δlon,Δlat = data["resolution"]

lonr = minlon:Δlon:maxlon
latr = minlat:Δlat:maxlat

bathname = resolvedata(data["bathymetry"])
bathisglobal = get(data,"bathymetryisglobal",true)

varname = data["varname"]

obsname = resolvedata(data["observations"])
epsilon2 = data["epsilon2"]

# fixme just take one
value,lon,lat,depth,time,ids = divand.loadobs(Float64,obsname,"Salinity")
depthr = data["depth"]


divand.checkobs((lon,lat,depth,time),value,ids)

sz = (length(lonr),length(latr),length(depthr))

lenx = fill(data["len"][1],sz)
leny = fill(data["len"][2],sz)
lenz = [10+depthr[k]/15 for i = 1:sz[1], j = 1:sz[2], k = 1:sz[3]]

@show mean(lenz)
years = [data["years"][1]:data["years"][2]]


# winter: January-March    1,2,3
# spring: April-June       4,5,6
# summer: July-September   7,8,9
# autumn: October-December 10,11,12

monthlist = data["monthlist"]


#TS = divand.TimeSelectorYW(years,year_window,monthlist)
TS = divand.TimeSelectorYearListMonthList(years,monthlist)

# File name based on the variable (but all spaces are replaced by _)
filename = "Water_body_$(replace(varname,' ','_')).4Danl.nc"


ncglobalattrib,ncvarattrib =
    if haskey(data,"metadata")
        metadata = data["metadata"]        
        divand.SDNMetadata(metadata,filename,varname,lonr,latr)
    else
        Dict{String,String}(),Dict{String,String}()
    end

if isfile(filename)
   rm(filename) # delete the previous analysis
end

@time res = divand.diva3d((lonr,latr,depthr,TS),
              (lon,lat,depth,time),
              value,
              (lenx,leny,lenz),
              epsilon2,
              filename,varname,
              bathname = bathname,
              bathisglobal = bathisglobal,
              ncvarattrib = ncvarattrib,
              ncglobalattrib = ncglobalattrib,
       )

divand.saveobs(filename,(lon,lat,depth,time),ids)




