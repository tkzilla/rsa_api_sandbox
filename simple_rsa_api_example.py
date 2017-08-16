"""
Tektronix RSA_API Example
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
import os, time
import numpy as np
import matplotlib.pyplot as plt

# C:\Tektronix\RSA_API\lib\x64 needs to be added to the
# PATH system environment variable
os.chdir("C:\\Tektronix\\RSA_API\\lib\\x64")
rsa = cdll.LoadLibrary("RSA_API.dll")


"""################CLASSES AND FUNCTIONS################"""


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


def search_connect():
    # Searches for and connects to the RSA and presets it
    DEVSRCH_MAX_NUM_DEVICES = 20
    DEVSRCH_SERIAL_MAX_STRLEN = 100
    DEVSRCH_TYPE_MAX_STRLEN = 20
    DEVINFO_MAX_STRLEN = 100

    numFound = c_int(0)
    intArray = c_int * DEVSRCH_MAX_NUM_DEVICES
    deviceIDs = intArray()
    deviceSerial = create_string_buffer(DEVSRCH_SERIAL_MAX_STRLEN)
    deviceType = create_string_buffer(DEVSRCH_TYPE_MAX_STRLEN)
    apiVersion = create_string_buffer(DEVINFO_MAX_STRLEN)

    rsa.DEVICE_GetAPIVersion(apiVersion)
    print('API Version {}'.format(apiVersion.value.decode()))

    rsa.DEVICE_Search(byref(numFound), deviceIDs,
                                deviceSerial, deviceType)

    if numFound.value < 1:
        # rsa.DEVICE_Reset(c_int(0))
        print('No instruments found. Exiting script.')
        exit()
    elif numFound.value == 1:
        print('One device found.')
        print('Device type: {}'.format(deviceType.value.decode()))
        print('Device serial number: {}'.format(deviceSerial.value.decode()))
        rsa.DEVICE_Connect(deviceIDs[0])
    else:
        # corner case
        print('2 or more instruments found. Exiting script')
    rsa.CONFIG_Preset()


"""################SPECTRUM EXAMPLE################"""

def peak_power_detector(freq, trace):
    peakPower = np.amax(trace)
    peakFreq = freq[np.argmax(trace)]

    return peakPower, peakFreq


def config_spectrum(cf=1e9, refLevel=0, span=3e9, rbw=1e6):
    rsa.SPECTRUM_SetEnable(c_bool(True))
    rsa.CONFIG_SetCenterFreq(c_double(cf))
    rsa.CONFIG_SetReferenceLevel(c_double(refLevel))
    
    rsa.SPECTRUM_SetDefault()
    
    specSet = Spectrum_Settings()
    rsa.SPECTRUM_GetSettings(byref(specSet))
    
    specSet.window = c_int(0)
    specSet.verticalUnit = c_int(0)
    specSet.span = span
    specSet.rbw = rbw
    
    rsa.SPECTRUM_SetSettings(specSet)
    rsa.SPECTRUM_GetSettings(byref(specSet))
    return specSet


def create_frequency_array(specSet):
    # Create array of frequency data for plotting the spectrum.
    return np.arange(specSet.actualStartFreq, specSet.actualStartFreq
                     + specSet.actualFreqStepSize * specSet.traceLength,
                     specSet.actualFreqStepSize)


def acquire_spectrum(specSet):
    # Spectrum acquisition variables
    ready = c_bool(False)
    traceArray = c_float * specSet.traceLength
    traceData = traceArray()
    outTracePoints = c_int(0)
    traceSelector = c_int(0)
    
    numTests = 100
    times = []
    
    # Acquisition
    rsa.DEVICE_Run()
    for i in range(numTests):
        t1 = time.perf_counter()
        rsa.SPECTRUM_AcquireTrace()
        while not ready.value:
            rsa.SPECTRUM_WaitForDataReady(c_int(1), byref(ready))
        rsa.SPECTRUM_GetTrace(traceSelector, specSet.traceLength, byref(traceData),
                              byref(outTracePoints))
        times.append(time.perf_counter()-t1)
    rsa.DEVICE_Stop()
    print('Total tests: {}, average time: {}'.format(numTests, np.mean(times))

    # convert trace data from ctypes array to a numpy array
    trace = np.array(traceData)
    return trace


def spectrum_example():
    print('########Spectrum Example########')
    search_connect()
    cf = 2.4453e9    
    refLevel = -0
    span = 40e6
    rbw = 10e3
    specSet = config_spectrum(cf, refLevel, span, rbw)
    trace = acquire_spectrum(specSet)
    freq = create_frequency_array(specSet)
    peakPower, peakFreq = peak_power_detector(freq, trace)
    
    plt.figure(1, figsize=(15, 10))
    ax = plt.subplot(111, facecolor='k')
    ax.plot(freq, trace, color='y')
    ax.set_title('Spectrum Trace')
    ax.set_xlabel('Frequency (Hz)')
    ax.set_ylabel('Amplitude (dBm)')
    ax.axvline(peakFreq)
    ax.text((freq[0] + specSet.span / 20), peakPower,
            'Peak power in spectrum: {:.2f} dBm @ {} MHz'.format(
                peakPower, peakFreq / 1e6), color='white')
    ax.set_xlim([freq[0], freq[-1]])
    ax.set_ylim([refLevel - 100, refLevel])
    plt.tight_layout()
    plt.show()
    rsa.DEVICE_Disconnect()


def main():
    spectrum_example()

if __name__ == '__main__':
    main()
    