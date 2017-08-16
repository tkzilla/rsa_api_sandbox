from rsa_api import *
import matplotlib.pyplot as plt
from pickle import dump
import pandas as pd

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


"""################SPECTRUM EXAMPLE################"""
def config_spectrum(cf=1e9, refLevel=0, span=40e6, rbw=300e3):
    SPECTRUM_SetEnable_py(True)
    CONFIG_SetCenterFreq_py(cf)
    CONFIG_SetReferenceLevel_py(refLevel)
    
    SPECTRUM_SetDefault_py()
    SPECTRUM_SetSettings_py(span=span, rbw=rbw, traceLength=801)
    specSet = SPECTRUM_GetSettings_py()
    return specSet


def create_frequency_array(specSet):
    # Create array of frequency data for plotting the spectrum.
    freq = np.arange(specSet['actualStartFreq'], specSet['actualStartFreq']
                     + specSet['actualFreqStepSize'] * specSet['traceLength'],
                     specSet['actualFreqStepSize'])
    return freq


def spectrum_example():
    print('\n\n########Spectrum Example########')
    search_connect()
    cf = 2.4453e9
    refLevel = 0
    span = 40e6
    rbw = 10e3
    specSet = config_spectrum(cf, refLevel, span, rbw)
    trace = SPECTRUM_Acquire_py(SpectrumTraces.SpectrumTrace1, specSet[
        'traceLength'], 100)
    freq = create_frequency_array(specSet)
    peakPower, peakFreq = peak_power_detector(freq, trace)
    
    plt.figure(1, figsize=(15, 10))
    ax = plt.subplot(111, facecolor='k')
    ax.plot(freq, trace, color='y')
    ax.set_title('Spectrum Trace')
    ax.set_xlabel('Frequency (Hz)')
    ax.set_ylabel('Amplitude (dBm)')
    ax.axvline(peakFreq)
    ax.text((freq[0] + specSet['span'] / 20), peakPower,
            'Peak power in spectrum: {:.2f} dBm @ {} MHz'.format(
                peakPower, peakFreq / 1e6), color='white')
    ax.set_xlim([freq[0], freq[-1]])
    ax.set_ylim([refLevel - 100, refLevel])
    plt.tight_layout()
    plt.show()
    DEVICE_Disconnect_py()
    
    
def calc_int_power(trace, span, rbw, tLength):
    #convert dBm to mW and normalize to span
    mW = 10**(trace/10)*span/rbw/tLength
    # numerical integration --> total power in mW
    totPower = np.trapz(mW)
    # print('Total Power in dBm: {:.2f}'.format(10*np.log10(totPower)))
    return mW, totPower


def calc_channel_power(trace, f1, f2, freq, rbw):
    # Get indices of f1 and f2
    if f1 == f2 == 0:
        return 0
    else:
        f1Index = np.where(freq==f1)[0][0]
        f2Index = np.where(freq==f2)[0][0]
        # calculate integrated power betweeen f1 and f2
        mW = 10**(trace[f1Index:f2Index]/10)*(f2-f1)/rbw/(f2Index-f1Index)
        totPower = np.trapz(mW)
        # if totPower <= 0:
        # 	print('Total Power: {}'.format(totPower))
        # 	print('F1: {:.3f} GHz. F2: {:.3f} GHz'.format(f1/1e9, f2/1e9))
        # 	plt.figure(1)
        # 	plt.plot(freq, trace)
        # 	plt.show(block=False)
        return 10*np.log10(totPower)

def calc_obw_pcnt(trace, freq, span, rbw, tLength):
    #integrated power calculation
    mW, totPower = calc_int_power(trace, span, rbw, tLength)
    obwPcnt = 0.99

    # Sum the power of each point together working in from both sides of the
    # trace until the sum is > 1-obwPcnt of total power. When the sum is
    # reached, save the frequencies at which it occurs.
    psum = j = k = 0
    debug = []
    left = []
    right = []
    target = (1-obwPcnt)*totPower
    while psum <= target:
        # left side
        if psum <= target/2:
            j += 1
            psum += mW[j]
            left.append(mW[j])
        # right side
        else:
            k -= 1
            psum += mW[k]
            right.append(mW[k])
        debug.append(psum)
    f1 = freq[j]
    f2 = freq[k]

    if f2<f1:
        psum = j = k = 0
        while psum <= target:
        # right side
            if psum <= target/2:
                k -= 1
                psum += mW[k]
                right.append(mW[k])
            # left side
            else:
                j += 1
                psum += mW[j]
                left.append(mW[j])
            debug.append(psum)
        # if j == 0 or k == 0:
        # 	f1 = f2 = 0
        # else:
        f1 = freq[j]
        f2 = freq[k]
    # if f2-f1 > 25e6:
    # 	# print('F1: {:.3f} GHz. F2: {:.3f} GHz. OBW: {:.3f}'.format(f1/1e9, f2/1e9, (f2-f1)))
    # 	plt.figure(1)
    # 	plt.plot(freq, trace)
    # 	plt.axvline(freq[j], color='g')
    # 	plt.axvline(freq[k], color='r')
    # 	plt.show(block=False)
    # #occupied bandwidth is the difference between f1 and f2
    # obw = f2-f1
    # print('OBW: %f MHz' % (obw/1e6))
    #print('Power at f1: %3.2f dBm. Power at f2: %3.2f dBm' % (trace[j], trace[k]))
    return f1, f2


def calc_obw_db(trace, freq, dB):
    peakPower = np.amax(trace)
    l = r = 0
    t1 = (peakPower-dB)
    t2 = (peakPower-dB/2)
    # start from outside
    if (np.amax(trace) - np.amin(trace)) < dB:
        print('Insufficient SNR.')
        return 0, 0
    try:
        # go in further than you need to
        while trace[l] < t2:
            l+=1
        # then move back out
        while trace[l] > t1:
            l-=1
        # repeat for other side
        while trace[r] < t2:
            r-=1
        while trace[r] > t1:
            r+=1
    except IndexError as idx:
        print('r: {}\nl: {}'.format(r,l))
        print('{}, trying inside.'.format(idx))
        # plt.figure(5)
        # plt.plot(freq,trace)
        # plt.axvline(freq[l+1], color='red')
        # plt.axvline(freq[r-1], color='red')
        # plt.show()

        try:
            l = r = np.argmax(trace)
            # start from inside
            while trace[l] > (peakPower-dB):
                l -= 1
            while trace[r] > (peakPower-dB):
                r += 1
        except IndexError as idx:
            print('{}, setting f1 = f2 = 0.'.format(idx))
            return 0, 0

    return freq[l], freq[r]


def main():
    """################INITIALIZE VARIABLES################"""
    # main SA parameters
    tSetSize = 50
    
    cf = 2.418e9  # center freq
    refLevel = -20  # ref level
    attn = 0
    trigLevel = -50  # trigger level in dBm
    
    """################SEARCH/CONNECT################"""
    search_connect()
    
    """################CONFIGURE INSTRUMENT################"""
    CONFIG_Preset_py()
    CONFIG_SetCenterFreq_py(cf)
    CONFIG_SetReferenceLevel_py(refLevel)
    
    CONFIG_SetAutoAttenuationEnable_py(False)
    CONFIG_SetRFAttenuator_py(attn)
    CONFIG_SetRFPreampEnable_py(True)
    
    TRIG_SetTriggerMode_py(TriggerMode.triggered)
    TRIG_SetIFPowerTriggerLevel_py(trigLevel)
    TRIG_SetTriggerSource_py(TriggerSource.TriggerSourceIFPowerLevel)
    TRIG_SetTriggerPositionPercent_py(10)
    
    SPECTRUM_SetEnable_py(True)
    SPECTRUM_SetDefault_py()
    
    # configure desired spectrum settings
    # some fields are left blank because the default
    # values set by SPECTRUM_SetDefault() are acceptable
    span = 40e6
    rbw = 20e3
    # enableVBW =
    # vbw =
    traceLength = 801
    # window =
    # verticalUnit =
    # actualStartFreq =
    # actualFreqStepSize =
    # actualRBW =
    # actualVBW =
    # actualNumIQSamples =
    
    # set desired spectrum settings
    SPECTRUM_SetSettings_py(span=span, rbw=rbw, traceLength=traceLength)
    specSet = SPECTRUM_GetSettings_py()
    
    # print spectrum settings for sanity check
    # print_spectrum_settings(specSet)
    
    
    """################INITIALIZE DATA TRANSFER VARIABLES################"""
    # generate frequency array for plotting the spectrum
    freq = np.arange(specSet['actualStartFreq'],
                     specSet['actualStartFreq'] + specSet[
                         'actualFreqStepSize'] *
                     specSet['traceLength'],
                     specSet['actualFreqStepSize'])
    
    trace = np.zeros((tSetSize, specSet['traceLength']))
    validTraces = np.zeros((tSetSize, specSet['traceLength']))
    obw =  np.zeros((tSetSize,1))
    roughCF = np.zeros((tSetSize,1))
    chPow = np.zeros((tSetSize,1))
    peakPower = np.zeros((tSetSize,1))
    errors = []
    # f1e = []
    # f2e = []
    
    """################ACQUIRE/PROCESS DATA################"""
    # start acquisition
    print('Acquiring Data')
    for i in range(tSetSize):
        trace[i] = SPECTRUM_Acquire_py(SpectrumTraces.SpectrumTrace1, specSet[
            'traceLength'], 100)
        
        """################FEATURE CALCULATION################"""
        # f1, f2 = calc_obw_pcnt(trace[i], freq, specSet.span, specSet.actualRBW, specSet.traceLength)
        f1, f2 = calc_obw_db(trace[i], freq, 20)
        if (f2 - f1 > 0 and f2 - f1 < 25e6):
            obw[i] = f2 - f1
            roughCF[i] = np.mean([f1, f2])
            chPow[i] = calc_channel_power(trace[i], f1, f2, freq,
                                          specSet['actualRBW'])
            peakPower[i] = np.amax(trace[i])
            validTraces[i] = trace[i]
        # if obw[i] > 30e6:
        # 	f1,f2 = calc_obw_pcnt(trace[i], freq, specSet.span, specSet.actualRBW, specSet.traceLength)
        if f2 - f1 > 25e6:
            errors.append(trace[i])
            fig1 = plt.figure(1, figsize=(15,7))
            fig1.suptitle('>25e6')
            plt.subplot(111, facecolor='k')
            plt.title('>25')
            plt.plot(freq, trace[i])
            plt.axvline(f1, color='w')
            plt.axvline(f2, color='b')
            plt.show(block=False)
        # if obw[i] <= 0:
        # 	plt.figure(6)
        # 	plt.subplot(111, facecolor='y')
        # 	plt.title('<0')
        # 	plt.plot(freq,trace[i])
        # 	plt.axvline(f1, color='w')
        # 	plt.axvline(f2, color='b')
        # 	plt.show(block=False)
        
        
        # print('Rough CF: {:.3f} GHz'.format(roughCF[i]/1e9))
        # print('Channel power: {:.3f} dBm'.format(chPow[i]))
        # print('Peak Power: {:.3f} dBm'.format(peakPower[i]))
        # print('Occupied Bandwidth: {:.3f} MHz'.format(obw[i]/1e6))
        
        """################SPECTRUM PLOT################"""
        # #plot the spectrum trace (optional)
        # plt.figure(2, figsize=(20,10))
        # plt.subplot(111, facecolor='k')
        # plt.plot(freq, trace[i], 'y')
        # plt.xlabel('Frequency (Hz)')
        # plt.ylabel('Amplitude (dBm)')
        # plt.title('Spectrum')
        
        # #Place vertical bars at f1 and f2 and annotate measurement
        # plt.axvline(x=f1)
        # plt.axvline(x=f2)
        # plt.axvline(x=roughCF[i])
        # text_x = specSet.actualStartFreq + specSet.span/20
        # plt.text(text_x, np.amax(trace[i]), 'OBW: %5.4f MHz' % (obw[i]/1e6), color='white')
        
        # #BONUS clean up plot axes
        # xmin = np.amin(freq)
        # xmax = np.amax(freq)
        # plt.xlim(xmin,xmax)
        # ymin = np.amin(trace)-10
        # ymax = np.amax(trace)+10
        # plt.ylim(ymin,refLevel)
        # plt.show()
    
    with open('error_traces.pickle', 'wb') as f:
        dump(errors, f)
    print('Disconnecting.')
    DEVICE_Disconnect_py()
    
    """Save some features here"""
    # Feature matrix
    # delIndices = np.where(obw<=0)
    # np.delete(roughCF, delIndices)
    # np.delete(obw, delIndices)
    # np.delete(chPow, delIndices)
    # np.delete(peakPower, delIndices)
    X = np.concatenate((roughCF, obw, chPow, peakPower, validTraces), axis=1)
    print('X shape: ', X.shape)
    
    delMatrix = np.where(X[:,0]==0)
    print(delMatrix)
    X = np.delete(X, delMatrix, axis=0)
    
    traceIndices = ['TP{}'.format(i) for i in range(specSet['traceLength'])]
    
    df = pd.DataFrame(X)
    dfName = 'C:\\users\\mallison\\documents\\github\\rsa_api_sandbox' \
             '\\classifier\\ism_features.csv'
    with open(dfName, 'w') as f:
        header = ['Rough CF (Hz)', 'OBW (Hz)', 'Channel Power (dBm)',
                  'Peak Power (dBm)', *traceIndices]
        df.to_csv(f, header=header, index=False)
    
    # df = pd.DataFrame(X)
    # dfName = 'C:\\users\\mallison\\documents\\github\\rsa_api_sandbox' \
    #          '\\classifier\\ism_features_complete.csv'
    # with open(dfName, 'w') as f:
    #     header = ['Rough CF (Hz)', 'OBW (Hz)', 'Channel Power (dBm)',
    #               'Peak Power (dBm)', *traceIndices]
    #     df.to_csv(f, header=header, index=False)
    
    
    fig3 = plt.figure(3, figsize=(15,7))
    fig3.suptitle('OBW vs CF')
    plt.subplot(111)
    plt.scatter(np.array(roughCF) / 1e9, np.array(obw) / 1e6)
    plt.xlabel('Rough CF in GHz')
    plt.ylabel('OBW in MHz')
    plt.show()
    
    for i in range(len(trace)):
        plt.figure(1, figsize=(15,7))
        plt.plot(freq, trace[i])
    plt.show()


if __name__ == "__main__":
    main()
