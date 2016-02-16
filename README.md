# Custom Startup Extension
Assists moving typical PHP script startup routines and initializations into an extension. Class autoloading is 2%-10% faster than typical PHP autoloaders.

CentOS 6 requires devtoolset-2 to compile PHP_CPP.
> cd /etc/yum.repos.d
> wget http://people.centos.org/tru/devtools-2/devtools-2.repo
> yum --enablerepo=testing-devtools-2-centos-6 install devtoolset-2-gcc devtoolset-2-gcc-c++
> scl enable devtoolset-2 bash