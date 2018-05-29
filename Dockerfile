# build as:
# sudo docker build -t abarth/DIVA .

FROM ubuntu:18.04

MAINTAINER Alexander Barth <a.barth@ulg.ac.be>

EXPOSE 8001

USER root


RUN apt-get update
RUN apt-get install -y libnetcdf-dev netcdf-bin
RUN apt-get install -y unzip
RUN apt-get install -y ca-certificates curl libnlopt0 make gcc 
RUN apt-get install -y wget
RUN apt-get install -y emacs-nox
RUN apt-get install -y nginx supervisor

RUN wget -O /usr/share/emacs/site-lisp/julia-mode.el https://raw.githubusercontent.com/JuliaEditorSupport/julia-emacs/master/julia-mode.el

ADD utils/run.sh /usr/local/bin/run.sh

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

RUN i=divand;       julia --eval "Pkg.clone(\"https://github.com/gher-ulg/$i.jl\"); Pkg.build(\"$i\"); using $i"

RUN mkdir /home/DIVAnd/DIVAnd-REST
ADD . /home/DIVAnd/DIVAnd-REST

WORKDIR /home/DIVAnd/DIVAnd-REST


CMD ["bash", "/usr/local/bin/run.sh"]
