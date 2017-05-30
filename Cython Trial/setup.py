# usage: python setup.py build_ext --inplace
from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

setup(
    ext_modules=cythonize([Extension('rsa_api',
                  ['rsa_api.pyx'],
                  libraries=['RSA_API'],
                  include_dirs=['C:\\Tektronix\\RSA_API\\include'],
                  library_dirs=['C:\\Tektronix\\RSA_API\\lib\\x64'])])
)