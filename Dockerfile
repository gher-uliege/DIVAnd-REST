# build as:
# sudo docker build -t abarth/divand-rest .
# 
#FROM ubuntu:18.04
FROM ubuntu:16.04

MAINTAINER Alexander Barth <a.barth@ulg.ac.be>

EXPOSE 8002

USER root


RUN apt-get update
RUN apt-get install -y libnetcdf-dev netcdf-bin
RUN apt-get install -y unzip
RUN apt-get install -y ca-certificates curl libnlopt0 make gcc 
RUN apt-get install -y wget
RUN apt-get install -y emacs-nox
RUN apt-get install -y nginx supervisor
RUN apt-get install -y jq

RUN wget -O /usr/share/emacs/site-lisp/julia-mode.el https://raw.githubusercontent.com/JuliaEditorSupport/julia-emacs/master/julia-mode.el

# Install julia

ADD utils/install_julia.sh .
RUN bash install_julia.sh
RUN rm install_julia.sh

RUN useradd -ms /bin/bash DIVAnd

# install packages as user (to that the user can temporarily update them if necessary)
# and precompilation

USER DIVAnd

RUN julia --eval 'Pkg.init()'

RUN i=HTTP; julia --eval "Pkg.add(\"$i\"); using $i"
RUN i=JSON; julia --eval "Pkg.add(\"$i\"); using $i"
RUN i=NCDatasets; julia --eval "Pkg.add(\"$i\"); using $i"
RUN i=PhysOcean; julia --eval "Pkg.add(\"$i\"); using $i"

# issue https://github.com/bicycle1885/EzXML.jl/issues/64

RUN i=EzXML; julia --eval "Pkg.add(\"$i\")" || true
RUN rm /home/DIVAnd/.julia/v0.6/EzXML/deps/usr/lib/libxml2.so
RUN ln -s /usr/lib/x86_64-linux-gnu/libxml2.so.2.9.3 /home/DIVAnd/.julia/v0.6/EzXML/deps/usr/lib/libxml2.so
RUN i=EzXML; julia --eval "Pkg.build(\"$i\"); using $i"

RUN i=divand;    julia --eval "Pkg.clone(\"https://github.com/gher-ulg/$i.jl\"); Pkg.build(\"$i\"); using $i"

RUN mkdir /home/DIVAnd/DIVAnd-REST


ADD . /home/DIVAnd/DIVAnd-REST

WORKDIR /home/DIVAnd/DIVAnd-REST/


#RUN wget -O /home/DIVAnd/DIVAnd-REST/data/gebco_30sec_16.nc https://b2drop.eudat.eu/s/o0vinoQutAC7eb0/download 
#RUN wget -O /home/DIVAnd/DIVAnd-REST/data/WOD-Salinity.nc 'http://b2drop.eudat.eu/s/UsF3RyU3xB1UM2o/download' 

USER root

CMD supervisord --nodaemon --configuration /home/DIVAnd/DIVAnd-REST/utils/supervisor-app.conf
