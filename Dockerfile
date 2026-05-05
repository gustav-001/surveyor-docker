FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        autoconf \
        automake \
        zlib1g-dev \
        libbz2-dev \
        liblzma-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        libdeflate-dev \
        wget \
	unzip \
        ca-certificates \
&& rm -rf /var/lib/apt/lists/*

ARG SURVEYOR_VERSION=0.12.1

WORKDIR /opt

RUN wget -q https://github.com/Mesh89/SurVeyor/archive/refs/tags/${SURVEYOR_VERSION}.tar.gz \
    && tar -xzf ${SURVEYOR_VERSION}.tar.gz \
    && mv SurVeyor-${SURVEYOR_VERSION} SurVeyor \
    && rm ${SURVEYOR_VERSION}.tar.gz \
    && cd  SurVeyor \
    && ./build_htslib.sh \
    && cmake -DCMAKE_BUILD_TYPE=Release . \
    && make -j"$(nproc)"

RUN wget -q https://github.com/Mesh89/SurVeyor/releases/download/${SURVEYOR_VERSION}/trained-model.zip \
    && unzip -q trained-model.zip -d /opt/SurVeyor/ \
    && rm trained-model.zip

FROM ubuntu:22.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        zlib1g \
        libbz2-1.0 \
        liblzma5 \
        libcurl4 \
        libssl3 \
        libdeflate0 \
        samtools \
&& rm -rf /var/lib/apt/lists/*

# put the versions of packages!
RUN pip3 install --no-cache-dir \
        numpy==2.2.6 \
        pysam==0.24.0 \
        scikit-learn==1.7.2 \
        xgboost==3.2.0 

COPY --from=builder /opt/SurVeyor /opt/SurVeyor

ENV PATH="/opt/SurVeyor/bin:${PATH}"

WORKDIR /data

ENTRYPOINT ["python3", "/opt/SurVeyor/surveyor.py"]

CMD ["--help"]


