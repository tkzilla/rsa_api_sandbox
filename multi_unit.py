"""
Tektronix RSA_API Multi-Unit Example
Date edited: 8/17
Windows 7 64-bit
RSA API version 3.11.0038
Python 3.6.1 64-bit (Anaconda 4.3.0)
NumPy 1.11.3, MatPlotLib 2.0.0
Download Anaconda: http://continuum.io/downloads
Anaconda includes NumPy and MatPlotLib
Download the RSA_API: http://www.tek.com/model/rsa306-software
"""

from ctypes import *
import os
from shutil import copyfile
from time import sleep
from RSA_API import *


# C:\Tektronix\RSA_API\lib\x64 needs to be added to the
# PATH system environment variable
os.chdir("C:\\Tektronix\\RSA_API_3.11\\lib\\x64")


def err_check(rs):
    if ReturnStatus(rs) != ReturnStatus.noError:
        raise RSAError(ReturnStatus(rs).name)

def multi_search_connect(selection=0):
    src = "RSA_API.dll"
    dst = "RSA_API_{}.dll".format(selection)
    copyfile(src, dst)
    rsa = cdll.LoadLibrary(dst)
    numFound = c_int(0)
    intArray = c_int * DEVSRCH_MAX_NUM_DEVICES
    deviceIDs = intArray()
    deviceSerial = create_string_buffer(DEVSRCH_SERIAL_MAX_STRLEN)
    deviceType = create_string_buffer(DEVSRCH_TYPE_MAX_STRLEN)
    apiVersion = create_string_buffer(DEVINFO_MAX_STRLEN)

    rsa.DEVICE_GetAPIVersion(apiVersion)
    print('API Version {}'.format(apiVersion.value.decode()))

    err_check(rsa.DEVICE_Search(byref(numFound), deviceIDs,
                                deviceSerial, deviceType))

    if numFound.value < 1:
        # rsa.DEVICE_Reset(c_int(0))
        print('No instruments found. Exiting script.')
        exit()
    elif numFound.value == 1:
        print('One device found.')
        print('Device type: {}'.format(deviceType.value.decode()))
        print('Device serial number: {}'.format(deviceSerial.value.decode()))
        err_check(rsa.DEVICE_Connect(deviceIDs[0]))
    else:
        # corner case
        print('2 or more instruments found. Connection to selected device.')
        err_check(rsa.DEVICE_Connect(deviceIDs[selection]))
        rsa.DEVICE_GetSerialNumber(deviceSerial)
        rsa.DEVICE_GetNomenclature(deviceType)
        print('Device type: {}'.format(deviceType.value.decode()))
        print('Device serial number: {}'.format(deviceSerial.value.decode()))
        
    rsa.CONFIG_Preset()
    return rsa


"""################IQ STREAMING EXAMPLE################"""
def config_iq_stream(rsa, cf=1e9, refLevel=0, bw=10e6,
                     fileDir='C:\\SignalVu-PC Files',
                     fileName='iq_stream_test', dest=IQSOUTDEST.IQSOD_FILE_SIQ,
                     suffixCtl=IQSSDFN_SUFFIX_NONE,
                     dType=IQSOUTDTYPE.IQSODT_INT16,
                     durationMsec=100):
    filenameBase = fileDir + '\\' + fileName
    bwActual = c_double(0)
    sampleRate = c_double(0)
    rsa.CONFIG_SetCenterFreq(c_double(cf))
    rsa.CONFIG_SetReferenceLevel(c_double(refLevel))
    
    rsa.IQSTREAM_SetAcqBandwidth(c_double(bw))
    rsa.IQSTREAM_SetOutputConfiguration(dest, dType)
    rsa.IQSTREAM_SetDiskFilenameBase(c_char_p(filenameBase.encode()))
    rsa.IQSTREAM_SetDiskFilenameSuffix(suffixCtl)
    rsa.IQSTREAM_SetDiskFileLength(c_int(durationMsec))
    rsa.IQSTREAM_GetAcqParameters(byref(bwActual), byref(sampleRate))
    rsa.IQSTREAM_ClearAcqStatus()


def iqstream_status_parser(iqStreamInfo):
    # This function parses the IQ streaming status variable
    status = iqStreamInfo.acqStatus
    if status == 0:
        print('\nNo error.\n')
    if bool(status & 0x10000):  # mask bit 16
        print('\nInput overrange.\n')
    if bool(status & 0x40000):  # mask bit 18
        print('\nInput buffer > 75{} full.\n'.format('%'))
    if bool(status & 0x80000):  # mask bit 19
        print('\nInput buffer overflow. IQStream processing too slow, ',
              'data loss has occurred.\n')
    if bool(status & 0x100000):  # mask bit 20
        print('\nOutput buffer > 75{} full.\n'.format('%'))
    if bool(status & 0x200000):  # mask bit 21
        print('Output buffer overflow. File writing too slow, ',
              'data loss has occurred.\n')


def multi_iq_stream_example():
    cf = 2.4453e9
    bw = 10e6
    dest = IQSOUTDEST.IQSOD_FILE_SIQ
    durationMsec = 100
    waitTime = 0.1
    iqStreamInfo = IQSTREAM_File_Info()
    
    complete = c_bool(False)
    writing = c_bool(False)
    
    config_iq_stream(rsa0, cf=2.42e9, bw=bw, dest=dest,
                     durationMsec=durationMsec, filename='rsa0_iq')
    config_iq_stream(rsa1, cf=2.46e9, bw=bw, dest=dest,
                     durationMsec=durationMsec, filename='rsa1_iq')
    
    rsa0.DEVICE_Run()
    rsa0.DEVICE_Run()
    rsa1.IQSTREAM_Start()
    rsa1.IQSTREAM_Start()
    while not complete.value:
        sleep(waitTime)
        rsa.IQSTREAM_GetDiskFileWriteStatus(byref(complete), byref(writing))
    rsa.IQSTREAM_Stop()
    print('Streaming finished.')
    rsa.IQSTREAM_GetFileInfo(byref(iqStreamInfo))
    iqstream_status_parser(iqStreamInfo)
    rsa.DEVICE_Stop()
    rsa.DEVICE_Disconnect()
    
    

def main():
    rsa0 = multi_search_connect(0)
    rsa1 = multi_search_connect(1)

    complete0 = c_bool(False)
    writing0 = c_bool(False)
    complete1 = c_bool(False)
    writing1 = c_bool(False)
    iqStreamInfo0 = IQSTREAM_File_Info()
    iqStreamInfo1 = IQSTREAM_File_Info()

    config_iq_stream(rsa0, cf=2.40e9, bw=40e6, durationMsec=100,
                     dest=IQSOUTDEST.IQSOD_FILE_TIQ,
                     fileName='rsa0_iq')
    config_iq_stream(rsa1, cf=2.44e9, bw=40e6, durationMsec=100,
                     dest=IQSOUTDEST.IQSOD_FILE_TIQ,
                     fileName='rsa1_iq')
    
    rsa0.DEVICE_Run()
    rsa1.DEVICE_Run()
    
    print('IQ Streaming Started')
    rsa0.IQSTREAM_Start()
    rsa1.IQSTREAM_Start()
    
    while not complete0.value and not complete1.value:
        sleep(0.1)
        rsa0.IQSTREAM_GetDiskFileWriteStatus(byref(complete0), byref(writing0))
        rsa1.IQSTREAM_GetDiskFileWriteStatus(byref(complete1), byref(writing1))

    rsa0.IQSTREAM_Stop()
    rsa1.IQSTREAM_Stop()
    print('Streaming finished.')
    
    rsa0.IQSTREAM_GetFileInfo(byref(iqStreamInfo0))
    rsa1.IQSTREAM_GetFileInfo(byref(iqStreamInfo1))
    iqstream_status_parser(iqStreamInfo0)
    iqstream_status_parser(iqStreamInfo1)
    
    rsa0.DEVICE_Stop()
    rsa1.DEVICE_Stop()
    rsa0.DEVICE_Disconnect()
    rsa1.DEVICE_Disconnect()
    
    try:
        os.remove("C:\\Tektronix\\RSA_API_3.11\\lib\\x64\\RSA_API_0.dll")
        os.remove("C:\\Tektronix\\RSA_API_3.11\\lib\\x64\\RSA_API_1.dll")
    except PermissionError:
        print('You don\'t have permission to delete these files.')
    
if __name__ == '__main__':
    main()
