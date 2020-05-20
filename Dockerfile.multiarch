# To build CIVET on non-x86_64 arch, two important patches are applied by this Dockerfile.
# - the output folder is renamed from "Linux-x86_64" to "dist"
# - config.guess is updated to a recent version
#
# Tested on linux/amd64, linux/ppc64le

FROM ubuntu:18.04 as base
RUN ["apt-get", "update", "-qq"]
# RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
# RUN apt-get install -qq ttf-mscorefonts-installer
RUN ["apt-get", "install", "-qq", "--no-install-recommends", "perl", "imagemagick", "gnuplot-nox", "locales"]

FROM base as builder
RUN ["apt-get", "install", "-qq", "git-lfs"]

RUN ["apt-get", "install", "-qq", "build-essential", "automake", "libtool", "bison"]
RUN ["apt-get", "install", "-qq", "libz-dev", "libjpeg-dev", "libpng-dev", "libtiff-dev", \
    "liblcms2-dev", "flex", "libx11-dev", "freeglut3-dev", \
    "libxmu-dev", "libxi-dev", "libqt4-dev"]

RUN ["rm", "/bin/sh"]
RUN ["ln", "-s", "/bin/bash", "/bin/sh"]

# use HTTPS instead of SSH for git clone
RUN ["git", "config", "--global", "url.https://github.com/.insteadOf", "git@github.com:"]

COPY . /opt/CIVET
WORKDIR /opt/CIVET
RUN ["git", "lfs", "pull"]

# change name of output folder from "Linux-x86_64" to "dist"
RUN ["sed", "-ri", "s/`uname`-`uname -m`/dist/", "install.sh"]
RUN ["sed", "-i", "s/^UNAME\\s*=.*$/UNAME = dist/", "Makefile"]

ARG MAKE_FLAGS

# extract all files in preparation for patching
RUN make $MAKE_FLAGS USE_GIT=yes untar
# update config.guess to a recent version
RUN ["provision/update_guess.sh", "provision/config.guess", "dist/SRC/"]
# copy configuration so installation can be non-interactive
COPY provision/netpbm/Makefile.config dist/SRC/netpbm-10.35.94/Makefile.config

# compile
RUN ["bash", "install.sh"]
# optional, run test job: docker build --build-arg run_test=y .
ARG run_test
RUN [ -z "$run_test" ] || ./job_test

# clean up build files before copying artifacts to final image
WORKDIR /opt/CIVET/dist
RUN ["rm", "-r", "SRC", "building", "info", "man"]

# multi-stage build
FROM base
COPY --from=builder /opt/CIVET/dist/ /opt/CIVET/dist/

# init.sh environment variables, should be equivalent to
# printf "%s\n\n" "source /opt/CIVET/Linux-x86_64/init.sh" >> ~/.bashrc
ENV MNIBASEPATH=/opt/CIVET/dist CIVET=CIVET-2.1.1
ENV PATH=$MNIBASEPATH/$CIVET:$MNIBASEPATH/$CIVET/progs:$MNIBASEPATH/bin:$PATH \
    LD_LIBRARY_PATH=$MNIBASEPATH/lib \
    MNI_DATAPATH=$MNIBASEPATH/share \
    PERL5LIB=$MNIBASEPATH/perl \
    R_LIBS=$MNIBASEPATH/R_LIBS \
    VOLUME_CACHE_THRESHOLD=-1 \
    BRAINVIEW=$MNIBASEPATH/share/brain-view \
    MINC_FORCE_V2=1 \
    MINC_COMPRESS=4 \
    CIVET_JOB_SCHEDULER=DEFAULT

CMD ["/opt/CIVET/dist/CIVET-2.1.1/CIVET_Processing_Pipeline", "-help"]
