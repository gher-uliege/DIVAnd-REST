# build as:
# sudo docker build -t abarth/DIVAnd-rest .
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
RUN apt-get install -y git

RUN wget -O /usr/share/emacs/site-lisp/julia-mode.el https://raw.githubusercontent.com/JuliaEditorSupport/julia-emacs/master/julia-mode.el

# Install julia

ADD utils/install_julia.sh .
RUN bash install_julia.sh
RUN rm install_julia.sh

RUN useradd -ms /bin/bash DIVAnd

# install packages as user (to that the user can temporarily update them if necessary)
# and precompilation

USER DIVAnd

#RUN julia --eval 'using Pkg; Pkg.init()'

RUN julia --eval "using Pkg; Pkg.add(PackageSpec(name=\"HTTP\", version=\"0.8\")); using HTTP"
RUN i=JSON; julia --eval "using Pkg; Pkg.add(\"$i\"); using $i"
RUN i=NCDatasets; julia --eval "using Pkg; Pkg.add(\"$i\"); using $i"
#RUN i=PhysOcean; julia --eval "using Pkg; Pkg.add(\"$i\"); using $i"
RUN i=PhysOcean; julia --eval "using Pkg; Pkg.clone(\"https://github.com/gher-ulg/$i.jl\"); Pkg.build(\"$i\"); using $i"

RUN i=EzXML; julia --eval "using Pkg; Pkg.add(\"$i\"); using $i"

RUN i=DIVAnd; julia --eval "using Pkg; Pkg.clone(\"https://github.com/gher-ulg/$i.jl\"); Pkg.build(\"$i\"); using $i"
RUN cd ~/.julia/dev/DIVAnd/;  git checkout Alex; git pull

RUN i=DataStructures; julia --eval "using Pkg; Pkg.add(\"$i\"); using $i"

#RUN i=PyPlot; julia --eval "using Pkg; Pkg.add(\"$i\"); using $i"
#RUN i=OceanPlot; julia --eval "using Pkg; Pkg.add(\"https://github.com/gher-ulg/$i.jl\"); Pkg.build(\"$i\"); using $i"

RUN julia --eval "using Pkg; Pkg.add(PackageSpec(name=\"Tables\", version=\"0.1.12\"))"
RUN julia --eval "using Pkg; Pkg.add(PackageSpec(name=\"Mustache\", version=\"0.5.8\"))"
RUN julia --eval 'using Pkg;   pkg"add https://github.com/Alexander-Barth/WebDAV.jl"'
RUN julia --eval "using Pkg; pkg\"precompile\""

RUN mkdir /home/DIVAnd/DIVAnd-REST


ADD . /home/DIVAnd/DIVAnd-REST

WORKDIR /home/DIVAnd/DIVAnd-REST/

USER root
RUN cd data; ./getdata.sh

RUN chown DIVAnd /home/DIVAnd/DIVAnd-REST/test/test_analysis2.json

CMD supervisord --nodaemon --configuration /home/DIVAnd/DIVAnd-REST/utils/supervisor-app.conf
