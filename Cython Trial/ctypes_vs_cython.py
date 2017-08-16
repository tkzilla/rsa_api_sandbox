"""
Ctypes vs Cython
Tektronix RSA_API Example
Date Created: 7/17
Date edited: 7/17
Windows 7 64-bit
RSA API version 3.9.0029
Python 3.6.1 64-bit (Anaconda 4.3.0)
NumPy 1.11.3, MatPlotLib 2.0.0
Download Anaconda: http://continuum.io/downloads
Anaconda includes NumPy and MatPlotLib
Download the RSA_API: http://www.tek.com/model/rsa306-software
"""

from ctypes import *
import numpy as np
import matplotlib.pyplot as plt
import os

# os.chdir("C:\\Tektronix\\RSA_API\\lib\\x64")
rsa = cdll.LoadLibrary('RSA_API.dll')

from rsa_api import *

def search_connect_ctypes():
    numFound = c_int(0)
    intArray = c_int * 10
    deviceIDs = intArray()
    deviceSerial = create_string_buffer(20)
    deviceType = create_string_buffer(20)

    rsa.DEVICE_Search(byref(numFound), deviceIDs, deviceSerial, deviceType)
    rsa.DEVICE_Connect(deviceIDs[0])
    rsa.CONFIG_Preset()
    
    print('Serial Number: ', deviceSerial.value.decode())
    print('Device Type: ', deviceType.value.decode())


def search_connect_cython():
    numDevicesFound, deviceIDs, deviceSerial, deviceType = DEVICE_Search_py()
    DEVICE_Connect_py(deviceIDs[0])
    CONFIG_Preset_py()

    print('Serial Number: ', deviceSerial[0].decode())
    print('Device Type: ', deviceType[0].decode())


def spectrum_config_ctypes():
    search_connect_ctypes()
    cf = 2.4453e9
    refLevel = 0
    span = 40e6
    rbw = 10e3
    

    class Spectrum_Settings(Structure):
        # Spectrum_Settings structure as defined by the API documentation
        _fields_ = [('span', c_double),
                    ('rbw', c_double),
                    ('enableVBW', c_bool),
                    ('vbw', c_double),
                    ('traceLength', c_int),
                    ('window', c_int),
                    ('verticalUnit', c_int),
                    ('actualStartFreq', c_double),
                    ('actualStopFreq', c_double),
                    ('actualFreqStepSize', c_double),
                    ('actualRBW', c_double),
                    ('actualVBW', c_double),
                    ('actualNumIQSamples', c_double)]
    
    
    rsa.CONFIG_SetCenterFreq(c_double(cf))
    rsa.CONFIG_SetReferenceLevel(c_double(refLevel))
    rsa.SPECTRUM_SetEnable(c_bool(True))
    rsa.SPECTRUM_SetDefault()
    specSet = Spectrum_Settings()
    rsa.SPECTRUM_GetSettings(byref(specSet))
    specSet.window = c_int(0)
    specSet.span = span
    specSet.rbw = rbw
    rsa.SPECTRUM_SetSettings(specSet)
    rsa.SPECTRUM_GetSettings(byref(specSet))
    

def acquire_spectrum_ctypes():
    traceLength = 801
    ready = c_bool(False)
    traceArray = c_float * traceLength
    traceData = traceArray()
    outTracePoints = c_int(0)
    traceSelector = c_int(0)
    
    # Acquisition
    rsa.DEVICE_Run()
    rsa.SPECTRUM_AcquireTrace()
    while not ready.value:
        rsa.SPECTRUM_WaitForDataReady(c_int(100), byref(ready))
    rsa.SPECTRUM_GetTrace(traceSelector, traceLength, byref(traceData),
                          byref(outTracePoints))
    rsa.DEVICE_Stop()
    
    # convert trace data from ctypes array to a numpy array
    trace = np.array(traceData)
    plt.figure(1, figsize=(15, 10))
    ax = plt.subplot(111, facecolor='k')
    ax.plot(trace, color='y')
    ax.set_title('Spectrum Trace')
    ax.set_xlabel('Frequency (Hz)')
    ax.set_ylabel('Amplitude (dBm)')
    plt.tight_layout()
    plt.show()
    rsa.DEVICE_Disconnect()
    

def spectrum_config_cython():
    search_connect_cython()
    cf = 2.4453e9
    refLevel = 0
    span = 40e6
    rbw = 10e3
    
    CONFIG_SetCenterFreq_py(cf)
    CONFIG_SetReferenceLevel_py(refLevel)
    
    SPECTRUM_SetEnable_py(True)
    SPECTRUM_SetDefault_py()
    SPECTRUM_SetSettings_py(span=span, rbw=rbw, traceLength=801)
    
    

def acquire_spectrum_cython():
    traceLength = 801
    trace = SPECTRUM_Acquire_py(SpectrumTraces.SpectrumTrace1, traceLength, 100)

    plt.figure(1, figsize=(15, 10))
    ax = plt.subplot(111, facecolor='k')
    ax.plot(trace, color='y')
    ax.set_title('Spectrum Trace')
    ax.set_xlabel('Frequency (Hz)')
    ax.set_ylabel('Amplitude (dBm)')
    plt.tight_layout()
    plt.show()
    DEVICE_Disconnect_py()
    
def main():
    spectrum_config_ctypes()
    acquire_spectrum_ctypes()
    
    spectrum_config_cython()
    acquire_spectrum_cython()

if __name__ == '__main__':
    main()
    