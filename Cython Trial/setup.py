# setup.py
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import numpy as np

ext_modules = [
	Extension('RSA_API', 
		['RSA_API.pyx'], 
		language='c++', 
		libraries=['RSA_API'], 
		library_dirs=['.','C:\\Tektronix\\RSA_API\\include',
		'C:\\Tektronix\\RSA_API\\lib\\x64'])
	]

setup(
	name='RSA_API', 
	cmdclass={'build_ext': build_ext},
	ext_modules=ext_modules,
	include_dirs=[np.get_include()]
	)