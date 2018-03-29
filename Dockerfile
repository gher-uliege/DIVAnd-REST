# build as:
# sudo docker build -t abarth/diva-julia .

FROM ubuntu:16.04

MAINTAINER Alexander Barth <a.barth@ulg.ac.be>

EXPOSE 8001

USER root

RUN apt-get update
RUN apt-get install -y libnetcdf-dev netcdf-bin
RUN apt-get install -y unzip
RUN apt-get install -y ca-certificates curl libnlopt0 make gcc 
RUN apt-get install -y emacs


RUN wget -O /usr/share/emacs/site-lisp/julia-mode.el https://raw.githubusercontent.com/JuliaEditorSupport/julia-emacs/master/julia-mode.el

ADD utils/run.sh /usr/local/bin/run.sh

# Install julia

ADD install_julia.sh .
RUN bash install_julia.sh
RUN rm install_julia.sh

RUN useradd -ms /bin/bash DIVAnd

# install packages as user (to that the user can temporarily update them if necessary)
# and precompilation

USER jovyan

RUN julia --eval 'Pkg.init()'

RUN i=ZMQ; julia --eval "Pkg.add(\"$i\"); using $i"
RUN i=Interpolations; julia --eval "Pkg.add(\"$i\"); using $i"
RUN i=MAT; julia --eval "Pkg.add(\"$i\"); using $i"
RUN i=JSON; julia --eval "Pkg.add(\"$i\"); using $i"
RUN i=SpecialFunctions; julia --eval "Pkg.add(\"$i\"); using $i"
RUN i=Roots; julia --eval "Pkg.add(\"$i\"); using $i"
RUN i=Requests; julia --eval "Pkg.add(\"$i\"); using $i"
RUN i=Gumbo; julia --eval "Pkg.add(\"$i\"); using $i"
RUN i=AbstractTrees; julia --eval "Pkg.add(\"$i\"); using $i"
RUN i=Glob; julia --eval "Pkg.add(\"$i\"); using $i"
RUN i=NCDatasets; julia --eval "Pkg.add(\"$i\"); using $i"

RUN i=PhysOcean; julia --eval "Pkg.add(\"$i\"); using $i"

RUN i=divand;      julia --eval "Pkg.clone(\"https://github.com/gher-ulg/$i.jl\"); Pkg.build(\"$i\"); using $i"


USER jovyan

#CMD ["bash", "/usr/local/bin/start-singleuser.sh","--KernelSpecManager.ensure_native_kernel=False"]

CMD ["bash", "/usr/local/bin/run.sh"]
