from rsa_api import *
from time import sleep
import numpy as np
import matplotlib.pyplot as plt


def search_connect():
    print('API Version {}'.format(DEVICE_GetAPIVersion_py()))
    try:
        numDevicesFound, deviceIDs, deviceSerial, deviceType = DEVICE_Search_py()
    except RSAError:
        print(RSAError)
    print('Number of devices: {}'.format(numDevicesFound))
    if numDevicesFound > 0:
        print('Device serial numbers: {}'.format(deviceSerial[0].decode()))
        print('Device type: {}'.format(deviceType[0].decode()))
        DEVICE_Connect_py(deviceIDs[0])
    else:
        print('No devices found, exiting script.')
        exit()
    CONFIG_Preset_py()


def config_block_iq(cf=1e9, refLevel=0, iqBw=40e6, recordLength=10000):
    CONFIG_SetCenterFreq_py(cf)
    CONFIG_SetReferenceLevel_py(refLevel)
    
    IQBLK_SetIQBandwidth_py(iqBw)
    IQBLK_SetIQRecordLength_py(recordLength)
    
    iqSampleRate = IQBLK_GetIQSampleRate_py()
    # Create array of time data for plotting IQ vs time
    time = np.linspace(0, recordLength / iqSampleRate, recordLength)
    time1 = []
    step = recordLength / iqSampleRate / (recordLength - 1)
    for i in range(recordLength):
        time1.append(i * step)
    return time


def block_iq_example():
    print('\n\n########Block IQ Example########')
    search_connect()
    cf = 100e6
    refLevel = 0
    iqBw = 40e6
    recordLength = 1024
    
    TRIG_SetTriggerMode_py()
    TRIG_SetTriggerSource_py()
    TRIG_SetTriggerPositionPercent_py()
    TRIG_SetIFPowerTriggerLevel_py(-10)
    
    time = config_block_iq(cf, refLevel, iqBw, recordLength)
    # IQ = IQBLK_Acquire_py(recordLength=recordLength)

    DEVICE_Run_py()
    IQBLK_AcquireIQData_py()
    while not IQBLK_WaitForIQDataReady_py(100):
        pass
    I, Q = IQBLK_GetIQDataDeinterleaved_py(recordLength)
    IQ = I + 1j*Q
    
    avf = np.fft.fft(IQ)
    pvf = np.fft.fft(np.angle(IQ))
    yes = np.fft.fftfreq(recordLength)
    freq = np.fft.fftshift(yes)
    
    fig = plt.figure(1, figsize=(10, 7))
    fig.suptitle('I and Q vs Time', fontsize='20')
    ax1 = plt.subplot(411, facecolor='k')
    ax1.plot(time * 1000, I, color='y')
    ax1.set_ylabel('I (V)')
    ax1.set_xlim([time[0] * 1e3, time[-1] * 1e3])
    
    ax2 = plt.subplot(412, facecolor='k')
    ax2.plot(time * 1000, Q, color='c')
    ax2.set_ylabel('Q (V)')
    ax2.set_xlabel('Time (msec)')
    ax2.set_xlim([time[0] * 1e3, time[-1] * 1e3])
    
    ax3 = plt.subplot(413, facecolor='k')
    ax3.plot(freq, avf, color='g')
    
    ax4 = plt.subplot(414, facecolor='k')
    ax4.plot(freq, pvf, color='r')
    
    plt.tight_layout()
    plt.show()
    DEVICE_Disconnect_py()
    

def main():
    block_iq_example()

if __name__ == '__main__':
    main()
    