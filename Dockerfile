FROM docker.io/library/centos:7
ADD adoptium.repo /etc/yum.repos.d/
ADD adoptium.gpg /etc/pki/rpm-gpg/
RUN yum update -y && \
    yum install -y centos-release-scl git python3 openssl-devel patch temurin-21-jdk && \
    yum install -y devtoolset-9 && \
    yum clean all && \
    rm -rf /var/cache/yum
COPY --chmod=0755 .bashrc /root
# Need this because GitHub Actions chooses to override $HOME
ENV BASH_ENV=/root/.bashrc
# Make sure devtoolset gets used during build
SHELL [ "/bin/bash", "-l", "-c" ]
RUN mkdir /maven && \
    cd /maven && \
    curl -O -L https://dlcdn.apache.org/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz && \
    echo "4810523ba025104106567d8a15a8aa19db35068c8c8be19e30b219a1d7e83bcab96124bf86dc424b1cd3c5edba25d69ec0b31751c136f88975d15406cab3842b  apache-maven-3.9.5-bin.tar.gz" | sha512sum -c && \
    tar -xvf apache-maven-3.9.5-bin.tar.gz && \
    mv apache-maven-3.9.5 /usr/local/src/apache-maven && \
    ln -s /usr/local/src/apache-maven/bin/mvn /usr/local/bin/mvn && \
    rm -rf /maven
RUN mkdir /cmake && \
    cd /cmake && \
    curl -O -L https://github.com/Kitware/CMake/releases/download/v3.27.8/cmake-3.27.8.tar.gz && \
    echo "ca7782caee11d487a21abcd1c00fce03f3172c718c70605568d277d5a8cad95a18f2bf32a52637935afb0db1102f0da92d5a412a7166e3f19be2767d6f316f3d  cmake-3.27.8.tar.gz" | sha512sum -c && \
    tar -xvf cmake-3.27.8.tar.gz && \
    cd cmake-3.27.8 && \
    ./bootstrap --parallel=$(nproc) && \
    make -j $(nproc) && \
    make install && \
    rm -rf /cmake
RUN mkdir /clang && \
    cd /clang && \
    curl -O -L https://github.com/llvm/llvm-project/releases/download/llvmorg-17.0.5/llvm-project-17.0.5.src.tar.xz && \
    echo "793b63aa875b6d02e3a2803815cc9361b76c9ab1506967e18630fc3d6811bf51c73f53c51d148a5fc72e87e35dc2b88cb18b48419939c436451fe65c5a326022  llvm-project-17.0.5.src.tar.xz" | sha512sum -c && \
    tar -xvf llvm-project-17.0.5.src.tar.xz && \
    cd llvm-project-17.0.5.src && \
    mkdir build && \
    cd build && \
    cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm && \
    make -j $(nproc) && \
    make install && \
    rm -rf /clang
ENTRYPOINT ["/bin/bash", "-l", "-c"]