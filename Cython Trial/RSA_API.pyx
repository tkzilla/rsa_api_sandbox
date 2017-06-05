from rsa_api_h cimport *
import numpy as np
import matplotlib.pyplot as plt

def err_check(rs):
    errMessage = DEVICE_GetErrorString(rs).decode()
    if errMessage != 'No Error':
        print(errMessage)
        # raise Exception(errMessage)

##########################################################
# Nameless Enums
##########################################################
AcqDataStatus_ADC_OVERRANGE = 0x1
AcqDataStatus_REF_OSC_UNLOCK = 0x2
AcqDataStatus_LOW_SUPPLY_VOLTAGE = 0x10
AcqDataStatus_ADC_DATA_LOST = 0x20
AcqDataStatus_VALID_BITS_MASK = (AcqDataStatus_ADC_OVERRANGE or AcqDataStatus_REF_OSC_UNLOCK or AcqDataStatus_LOW_SUPPLY_VOLTAGE or AcqDataStatus_ADC_DATA_LOST)

DEVSRCH_MAX_NUM_DEVICES = 20
DEVSRCH_SERIAL_MAX_STRLEN = 100
DEVSRCH_TYPE_MAX_STRLEN = 20

DEVINFO_MAX_STRLEN = 100

DEVEVENT_OVERRANGE = 0
DEVEVENT_TRIGGER = 1
DEVEVENT_1PPS = 2

IQBLK_STATUS_INPUT_OVERRANGE = (1 << 0)
IQBLK_STATUS_FREQREF_UNLOCKED = (1 << 1)
IQBLK_STATUS_ACQ_SYS_ERROR = (1 << 2)
IQBLK_STATUS_DATA_XFER_ERROR = (1 << 3)

DPX_TRACEIDX_1 = 0
DPX_TRACEIDX_2 = 1
DPX_TRACEIDX_3 = 2

IFSSDFN_SUFFIX_INCRINDEX_MIN = 0
IFSSDFN_SUFFIX_TIMESTAMP = -1
IFSSDFN_SUFFIX_NONE = -2

IQSSDFN_SUFFIX_INCRINDEX_MIN = 0
IQSSDFN_SUFFIX_TIMESTAMP = -1
IQSSDFN_SUFFIX_NONE = -2

IQSTRM_STATUS_OVERRANGE = (1 << 0)
IQSTRM_STATUS_XFER_DISCONTINUITY = (1 << 1)
IQSTRM_STATUS_IBUFF75PCT = (1 << 2)
IQSTRM_STATUS_IBUFFOVFLOW = (1 << 3)
IQSTRM_STATUS_OBUFF75PCT = (1 << 4)
IQSTRM_STATUS_OBUFFOVFLOW = (1 << 5)
IQSTRM_STATUS_NONSTICKY_SHIFT = 0
IQSTRM_STATUS_STICKY_SHIFT = 16

IQSTRM_MAXTRIGGERS = 100

IQSTRM_FILENAME_DATA_IDX = 0
IQSTRM_FILENAME_HEADER_IDX = 1


def device_connection_info():
    ##########################################################
    # Device Connection and Info
    ##########################################################
    print('\n########Device Connection########')
    cdef int numDevicesFound = 0
    cdef int deviceIDs[20]
    cdef char deviceSerial[20][100]
    cdef char deviceType[20][20]
    
    rs = DEVICE_Search(&numDevicesFound, deviceIDs, deviceSerial, deviceType)
    err_check(rs)
    
    devs = np.asarray(deviceIDs)
    
    print('Number of devices: {}'.format(numDevicesFound))
    print('Device serial numbers: {}'.format(deviceSerial[0].decode()))
    print('Device type: {}'.format(deviceType[0].decode()))
    
    DEVICE_Connect(devs[0])
    # print(DEVICE_GetErrorString(DEVICE_Reset(devs[0])))
    
    cdef bint tempStatus
    rs = DEVICE_GetOverTemperatureStatus(&tempStatus)
    err_check(rs)
    print('Temperature Status: {}'.format(tempStatus))
    
    cdef char nomenclature[100]
    rs = DEVICE_GetNomenclature(nomenclature)
    err_check(rs)
    print('Nomenclature: {}'.format(nomenclature.decode()))
    
    cdef char serialNum[100]
    rs = DEVICE_GetSerialNumber(serialNum)
    err_check(rs)
    print('Serial Number: {}'.format(serialNum.decode()))
    
    cdef char apiVersion[100]
    rs = DEVICE_GetAPIVersion(apiVersion)
    err_check(rs)
    print('API Version: {}'.format(apiVersion.decode()))
    
    cdef char fwVersion[100]
    rs = DEVICE_GetFWVersion(fwVersion)
    err_check(rs)
    print('Firmware Version: {}'.format(fwVersion.decode()))
    
    cdef char fpgaVersion[100]
    rs = DEVICE_GetFPGAVersion(fpgaVersion)
    err_check(rs)
    print('FPGA Version: {}'.format(fpgaVersion.decode()))
    
    cdef char hwVersion[100]
    rs = DEVICE_GetHWVersion(hwVersion)
    err_check(rs)
    print('Hardware Version: {}'.format(hwVersion.decode()))
    
    print('\nUsing DEVICE_GetInfo: ')
    cdef DEVICE_INFO devInfo
    rs = DEVICE_GetInfo(&devInfo)
    err_check(rs)
    print('Nomenclature: {}'.format(devInfo.nomenclature.decode()))
    print('Serial Number: {}'.format(devInfo.serialNum.decode()))
    print('API Version: {}'.format(devInfo.apiVersion.decode()))
    print('Firmware Version: {}'.format(devInfo.fwVersion.decode()))
    print('FPGA Version: {}'.format(devInfo.fpgaVersion.decode()))
    print('Hardware Version: {}'.format(devInfo.hwVersion.decode()))


def device_configuration():
    ##########################################################
    # Device Configuration (global)
    ##########################################################
    print('\n########Device Configuration########')
    CONFIG_Preset()
    cdef double refLevel = 0
    rs = CONFIG_SetReferenceLevel(refLevel)
    err_check(rs)
    rs = CONFIG_GetReferenceLevel(&refLevel)
    print('Reference Level: {}'.format(refLevel))
    
    cdef double maxCF
    cdef double minCF
    rs = CONFIG_GetMaxCenterFreq(&maxCF)
    err_check(rs)
    rs = CONFIG_GetMinCenterFreq(&minCF)
    err_check(rs)
    print('Max CF: {}\nMin CF: {}'.format(maxCF, minCF))
    
    cdef double cf = 2.4453e9
    rs = CONFIG_SetCenterFreq(cf)
    err_check(rs)
    rs = CONFIG_GetCenterFreq(&cf)
    err_check(rs)
    print('Center Frequency: {}'.format(cf))
    
    cdef bint exRefEn = 0
    rs = CONFIG_SetExternalRefEnable(exRefEn)
    err_check(rs)
    rs = CONFIG_GetExternalRefEnable(&exRefEn)
    err_check(rs)
    print('External Reference Status: {}'.format(exRefEn))
    
    cdef double extFreq
    rs = CONFIG_GetExternalRefFrequency(&extFreq)
    err_check(rs)
    print('External Frequency: {}'.format(extFreq))
    
    cdef bint autoAttenEnable = 0
    rs = CONFIG_SetAutoAttenuationEnable(autoAttenEnable)
    err_check(rs)
    rs = CONFIG_GetAutoAttenuationEnable(&autoAttenEnable)
    err_check(rs)
    print('Auto Attenuation Status: {}'.format(autoAttenEnable))
    
    cdef bint preampEnable = 1
    rs = CONFIG_SetRFPreampEnable(preampEnable)
    err_check(rs)
    rs = CONFIG_GetRFPreampEnable(&preampEnable)
    err_check(rs)
    print('Preamp Status: {}'.format(preampEnable))
    
    cdef double value = 0
    rs = CONFIG_SetRFAttenuator(value)
    err_check(rs)
    rs = CONFIG_GetRFAttenuator(&value)
    err_check(rs)
    print('Attenuator Value: {}'.format(value))


def trigger_configuration():
    ##########################################################
    #  Trigger Configuration
    ##########################################################
    print('\n########Trigger########')
    cdef TriggerMode mode = TriggerMode.freeRun
    rs = TRIG_SetTriggerMode(mode)
    err_check(rs)
    rs = TRIG_GetTriggerMode(&mode)
    err_check(rs)
    print('Trigger Mode: {}'.format(mode))
    
    cdef TriggerSource source = TriggerSource.TriggerSourceIFPowerLevel
    rs = TRIG_SetTriggerSource(source)
    err_check(rs)
    rs = TRIG_GetTriggerSource(&source)
    err_check(rs)
    print('Trigger Source: {}'.format(source))
    
    cdef TriggerTransition transition = TriggerTransition.TriggerTransitionHL
    rs = TRIG_SetTriggerTransition(transition)
    err_check(rs)
    rs = TRIG_GetTriggerTransition(&transition)
    err_check(rs)
    print('Trigger Transition: {}'.format(transition))
    
    cdef double level = -30
    rs = TRIG_SetIFPowerTriggerLevel(level)
    err_check(rs)
    rs = TRIG_GetIFPowerTriggerLevel(&level)
    err_check(rs)
    print('Trigger Level: {}'.format(level))
    
    cdef double trigPosPercent = 15
    rs = TRIG_SetTriggerPositionPercent(trigPosPercent)
    err_check(rs)
    rs = TRIG_GetTriggerPositionPercent(&trigPosPercent)
    err_check(rs)
    print('Trigger Position(%): {}'.format(trigPosPercent))
    
    rs = TRIG_ForceTrigger()
    err_check(rs)


def device_alignment():
    ##########################################################
    # Device Alignment
    ##########################################################
    print('\n########Device Alignment########')
    cdef bint warmedUp = False
    cdef bint needed = False
    rs = ALIGN_GetWarmupStatus(&warmedUp)
    err_check(rs)
    print('Warmup Status: {}'.format(warmedUp))
    rs = ALIGN_GetAlignmentNeeded(&needed)
    err_check(rs)
    print('Alignment Needed: {}'.format(needed))
    # rs = ALIGN_RunAlignment()
    err_check(rs)


def device_operation():
    ##########################################################
    # Device Operation (global)
    ##########################################################
    print('\n########Device Operation########')
    rs = DEVICE_PrepareForRun()
    err_check(rs)
    rs = DEVICE_Run()
    err_check(rs)
    cdef bint devEnable = True
    rs = DEVICE_GetEnable(&devEnable)
    err_check(rs)
    print('Device Enable: {}'.format(devEnable))
    rs = DEVICE_StartFrameTransfer()
    err_check(rs)
    rs = DEVICE_Stop()
    err_check(rs)
    
    # DEVEVENT_OVERRANGE = 0
    # DEVEVENT_TRIGGER = 1
    # DEVEVENT_1PPS = 2
    cdef int eventID = DEVEVENT_TRIGGER
    cdef bint eventOccurred = True
    cdef uint64_t eventTimestamp = 0
    rs = DEVICE_GetEventStatus(eventID, &eventOccurred, &eventTimestamp)
    err_check(rs)
    print('EventID: {}\nEvent Occurred: {}\nEvent Timestamp: {}'.format(
        eventID, eventOccurred, eventTimestamp))


def reference_time():
    ##########################################################
    # System/Reference Time
    ##########################################################
    print('\n########System/Reference Time########')
    cdef uint64_t o_refTimestampRate = 0
    rs = REFTIME_GetTimestampRate(&o_refTimestampRate)
    err_check(rs)
    print('Timestamp Rate: {}'.format(o_refTimestampRate))
    
    cdef Py_ssize_t o_timeSec = 0
    cdef uint64_t o_timeNsec = 0
    cdef uint64_t o_timestamp = 0
    cdef Py_ssize_t i_timeSec = 0
    cdef uint64_t i_timeNsec = 0
    cdef uint64_t i_timestamp = 0
    rs = REFTIME_GetCurrentTime(&o_timeSec, &o_timeNsec, &o_timestamp)
    err_check(rs)
    print('Current Time - sec: {} nsec: {} timestamp: {}'.format(
        o_timeSec, o_timeNsec, o_timestamp))
    
    rs = REFTIME_GetTimeFromTimestamp(i_timestamp, &o_timeSec, &o_timeNsec)
    err_check(rs)
    print('Time from Timestamp - sec: {} nsec: {}'.format(
        o_timeSec, o_timeNsec))
    
    rs = REFTIME_GetTimestampFromTime(i_timeSec, i_timeNsec, &o_timestamp)
    err_check(rs)
    print('Timestamp from Time: {}'.format(o_timestamp))
    
    cdef double sec = 0
    rs = REFTIME_GetIntervalSinceRefTimeSet(&sec)
    err_check(rs)
    print('Interval Since Reftime Set: {}'.format(sec))
    
    cdef Py_ssize_t refTimeSec = 1496247164
    cdef uint64_t refTimeNsec = 0
    cdef uint64_t refTimestamp = refTimeSec + refTimeNsec
    rs = REFTIME_SetReferenceTime(refTimeSec, refTimeNsec, refTimestamp)
    err_check(rs)
    
    rs = REFTIME_GetReferenceTime(&refTimeSec, &refTimeNsec, &refTimestamp)
    err_check(rs)
    print('Reference Time - sec: {} nsec: {} timestamp: {}'.format(
        refTimeSec, refTimeNsec, refTimestamp))


def iq_block_data():
    ##########################################################
    # IQ Block Data Acquisition
    ##########################################################
    print('\n########IQ Block########')
    cdef double maxBandwidth = 0
    cdef double minBandwidth = 0
    cdef int maxSamples = 0
    rs = IQBLK_GetMaxIQBandwidth(&maxBandwidth)
    err_check(rs)
    rs = IQBLK_GetMinIQBandwidth(&minBandwidth)
    err_check(rs)
    rs = IQBLK_GetMaxIQRecordLength(&maxSamples)
    err_check(rs)
    print('Max IQ BW: {}\nMin IQ BW: {}\nMax Samples {}'.format(
        maxBandwidth, minBandwidth, maxSamples))
    
    cdef double iqBandwidth = 20e6
    cdef double iqSampleRate = 0
    cdef int recordLength = 1000
    rs = IQBLK_SetIQBandwidth(iqBandwidth)
    err_check(rs)
    rs = IQBLK_GetIQBandwidth(&iqBandwidth)
    err_check(rs)
    rs = IQBLK_GetIQSampleRate(&iqSampleRate)
    err_check(rs)
    rs = IQBLK_SetIQRecordLength(recordLength)
    err_check(rs)
    rs = IQBLK_GetIQRecordLength(&recordLength)
    err_check(rs)
    print('IQ BW: {}\nIQ Sample Rate: {}\nRecord Length: {}'.format(
        iqBandwidth, iqSampleRate, recordLength))
    
    cdef bint ready = False
    cdef float iqDataIlv[2000]  # recordLength*2 preallocation
    cdef float iData[1000]
    cdef float qData[1000]
    cdef Cplx32 iqDataCplx[1000]
    cdef int outLength = 0
    cdef int reqLength = recordLength
    cdef int timeoutMsec = 100
    
    rs = DEVICE_Run()
    rs = IQBLK_AcquireIQData()
    while ready == 0:
        rs = IQBLK_WaitForIQDataReady(timeoutMsec, &ready)
        print('IQ Ready: {}'.format(ready))
    rs = IQBLK_GetIQData(iqDataIlv, &outLength, reqLength)
    err_check(rs)
    
    ready = False
    rs = DEVICE_Run()
    rs = IQBLK_AcquireIQData()
    while ready == 0:
        rs = IQBLK_WaitForIQDataReady(timeoutMsec, &ready)
        print('IQ Ready: {}'.format(ready))
    rs = IQBLK_GetIQDataDeinterleaved(iData, qData, &outLength, reqLength)
    err_check(rs)
    
    ready = False
    rs = DEVICE_Run()
    rs = IQBLK_AcquireIQData()
    while ready == 0:
        rs = IQBLK_WaitForIQDataReady(timeoutMsec, &ready)
        print('IQ Ready: {}'.format(ready))
    rs = IQBLK_GetIQDataCplx(iqDataCplx, &outLength, reqLength)
    err_check(rs)
    iqCplx = [(d['i'] + 1j * d['q']) for d in np.asarray(iqDataCplx)]

    cdef IQBLK_ACQINFO acqInfo
    rs = IQBLK_GetIQAcqInfo(&acqInfo)
    print('IQ Block Acquisition Info:\n{}'.format(acqInfo))
    err_check(rs)
    
    fig = plt.figure(1, figsize=(10,10))
    ax1 = fig.add_subplot(2,2,1)
    ax1.set_title('IQ Interleaved')
    ax1.plot(iqDataIlv)
    ax2 = fig.add_subplot(2,2,2)
    ax2.set_title('I Data')
    ax2.plot(iData)
    ax3 = fig.add_subplot(2,2,3)
    ax3.set_title('Q Data')
    ax3.plot(qData)
    ax4 = fig.add_subplot(2,2,4)
    ax4.set_title('IQ Complex')
    ax4.plot(np.real(iqCplx))
    plt.show()


def spectrum_acquisition():
    ##########################################################
    # Spectrum Acquisition
    ##########################################################
    print('\n########Spectrum########')
    cdef bint enable = True
    rs = SPECTRUM_SetEnable(enable)
    err_check(rs)
    rs = SPECTRUM_GetEnable(&enable)
    err_check(rs)
    print('Spectrum Enable: {}'.format(enable))
    
    rs = SPECTRUM_SetDefault()
    err_check(rs)
    
    cdef Spectrum_Settings settings
    rs = SPECTRUM_GetSettings(&settings)
    err_check(rs)
    print('Spectrum Settings:\n{}'.format(settings))
    rs = SPECTRUM_SetSettings(settings)
    err_check(rs)

    cdef SpectrumTraces trace = SpectrumTraces.SpectrumTrace1
    cdef SpectrumDetectors detector = SpectrumDetectors.SpectrumDetector_PosPeak
    rs = SPECTRUM_SetTraceType(trace, enable, detector)
    err_check(rs)
    rs = SPECTRUM_GetTraceType(trace, &enable, &detector)
    err_check(rs)
    print('Spectrum Trace {}, Enabled: {}, Detector Type: {}'.format(
        trace, enable, detector))
    
    cdef Spectrum_Limits limits
    rs = SPECTRUM_GetLimits(&limits)
    err_check(rs)
    print('Spectrum Limits:\n{}'.format(limits))
    
    cdef bint ready = False
    cdef int timeoutMsec = 100
    DEVICE_Run()
    rs = SPECTRUM_AcquireTrace()
    err_check(rs)
    while ready == 0:
        rs = SPECTRUM_WaitForTraceReady(timeoutMsec, &ready)
        err_check(rs)
    print('Spectrum Ready: {}'.format(ready))
    
    cdef int maxTracePoints = settings.traceLength
    cdef float traceData[801]
    cdef int outTracePoints = 0
    rs = SPECTRUM_GetTrace(trace, maxTracePoints, traceData, &outTracePoints)
    err_check(rs)
    
    cdef Spectrum_TraceInfo traceInfo
    rs = SPECTRUM_GetTraceInfo(&traceInfo)
    err_check(rs)
    print('Spectrum Trace Info:\n{}'.format(traceInfo))
    
    fig = plt.figure(2, figsize=(10,10))
    plt.plot(traceData)
    plt.title('Spectrum Trace')
    plt.show()
    
    
def dpx_acquisition():
    ##########################################################
    # DPX Bitmap, Trace, and Spectrogram
    ##########################################################
    
    # there is a problem when the spectrum or IQ examples are run before the
    # DPX example. This occurs right before grabbing the DPX_FrameBuffer
    # If the DPX example is run first, there is no problem.
    print('\n########DPX########')
    CONFIG_Preset()
    CONFIG_SetCenterFreq(2.4453e9)
    
    cdef double cf
    cdef double refLevel
    CONFIG_GetCenterFreq(&cf)
    CONFIG_GetReferenceLevel(&refLevel)
    print('CF: {}\nRefLevel: {}'.format(cf, refLevel))


    print('\nDPX Bitmap, Trace, and Spectrogram')
    cdef bint enable = True
    rs = DPX_SetEnable(enable)
    err_check(rs)
    rs = DPX_GetEnable(&enable)
    err_check(rs)
    print('DPX Enable: {}'.format(enable))
    rs = DPX_Reset()
    err_check(rs)
    
    cdef double fspan = 20e6
    cdef double rbw = 100e3
    cdef int32_t bitmapWidth = 801      # 0 <= 801
    cdef int32_t tracePtsPerPixel = 1   # 1, 3, or 5.
    # tracePoints = bitmapWidth*tracePtsPerPixel
    cdef VerticalUnitType yUnit = VerticalUnitType.VerticalUnit_dBm
    cdef double yTop = 0
    cdef double yBottom = yTop - 100
    cdef bint infinitePersistence = False
    cdef double persistenceTimeSec = 1
    cdef bint showOnlyTrigFrame = False
    rs = DPX_SetParameters(fspan, rbw, bitmapWidth, tracePtsPerPixel, yUnit,
                           yTop, yBottom, infinitePersistence,
                           persistenceTimeSec, showOnlyTrigFrame)
    err_check(rs)
    
    cdef bint enableSpectrum = True
    cdef bint enableSpectrogram = True
    rs = DPX_Configure(enableSpectrum, enableSpectrogram)
    err_check(rs)
    
    cdef DPX_SettingsStruct pSettings
    rs = DPX_GetSettings(&pSettings)
    err_check(rs)
    print('DPX Settings:\n{}'.format(pSettings))
    
    cdef int32_t traceIndex = 0
    cdef TraceType tType = TraceType.TraceTypeMax
    rs = DPX_SetSpectrumTraceType(traceIndex, tType)
    err_check(rs)
    
    cdef double minRBW
    cdef double maxRBW
    rs = DPX_GetRBWRange(fspan, &minRBW, &maxRBW)
    err_check(rs)
    print('Min DPX RBW: {}\nMax DPX RBW: {}'.format(minRBW, maxRBW))
    
    cdef double timePerBitmapLine = 0.1
    cdef double timeResolution = 0.01
    cdef double maxPower = 0
    cdef double minPower = maxPower - 100
    rs = DPX_SetSogramParameters(timePerBitmapLine, timeResolution,
                                 maxPower, minPower)
    err_check(rs)
    
    cdef TraceType traceType = TraceType.TraceTypeMax
    rs = DPX_SetSogramTraceType(traceType)
    err_check(rs)

    cdef bint frameAvailable = False
    cdef bint ready = False
    cdef int timeoutMsec = 100
    cdef DPX_FrameBuffer fb

    DEVICE_Run()
    while frameAvailable == 0:
        DPX_IsFrameBufferAvailable(&frameAvailable)
    while ready == 0:
        DPX_WaitForDataReady(timeoutMsec, &ready)
    rs = DPX_GetFrameBuffer(&fb)
    err_check(rs)
    rs = DPX_FinishFrameBuffer()
    err_check(rs)
    # DEVICE_Stop()
    
    cdef DPX_SogramSettingsStruct sSettings
    rs = DPX_GetSogramSettings(&sSettings)
    err_check(rs)
    print('DPX_SogramSettings: {}'.format(sSettings))
    
    cdef int64_t frameCount = 0
    cdef int64_t fftCount = 0
    rs = DPX_GetFrameInfo(&frameCount, &fftCount)
    err_check(rs)
    print('Frame Count: {}\nFFT Count: {}'.format(frameCount, fftCount))
    
    cdef int32_t lineCount = 0
    cdef double timestamp = 0
    rs = DPX_GetSogramHiResLineCountLatest(&lineCount)
    err_check(rs)
    print('Line Count: {}'.format((lineCount)))
    
    cdef bint triggered = False
    cdef int32_t lineIndex = 0
    rs = DPX_GetSogramHiResLineTriggered(&triggered, lineIndex)
    err_check(rs)
    print('Line {} Triggered: {}'.format(lineIndex, triggered))
    
    rs = DPX_GetSogramHiResLineTimestamp(&timestamp, lineIndex)
    err_check(rs)
    print('Line {} Timestamp: {}'.format(lineIndex, timestamp))
    
    # sogramBitmapWidth and sogramTravepoints are only ever 267
    cdef int16_t vData[267]
    cdef int32_t vDataSize = 0
    cdef double dataSF = 0
    cdef int32_t tracePoints = 267
    cdef int32_t firstValidPoint = 0
    rs = DPX_GetSogramHiResLine(vData, &vDataSize, lineIndex,
        &dataSF, tracePoints, firstValidPoint)
    err_check(rs)
    print('vData Size: {}'.format(vDataSize))
    
    print('FFT Per Frame: {}'.format(fb.fftPerFrame))
    print('FFT Count: {}'.format(fb.fftCount))
    print('Frame Count: {}'.format(fb.frameCount))
    print('Timestamp: {}'.format(fb.timestamp))
    print('Acq Data Status: {}'.format(fb.acqDataStatus))
    print('Minimum Signal Duration: {}'.format(fb.minSigDuration))
    print('Minimum Signal Duration out of range: {}'.format(fb.minSigDurOutOfRange))
    print('Spectrum Bitmap Width: {}, Height: {}, Size: {}'.format(
        fb.spectrumBitmapWidth, fb.spectrumBitmapHeight, fb.spectrumBitmapSize))
    print('Spectrum Trace Length: {}'.format((fb.spectrumTraceLength)))
    print('Number Spectrum Traces: {}'.format(fb.numSpectrumTraces))
    print('Spectrum Enabled: {}, Spectrogram Enabled: {}'.format(
        fb.spectrumEnabled, fb.spectrogramEnabled))
    print('Spectrogram Bitmap Width: {}, Height: {}, Size: {}'.format(
        fb.sogramBitmapWidth, fb.sogramBitmapHeight, fb.sogramBitmapSize))
    print('Spectrogram Valid Lines: {}'.format(fb.sogramBitmapNumValidLines))
    
    dpxBitmap = np.asarray(fb.spectrumBitmap)
    dpxBitmap = dpxBitmap.reshape((fb.spectrumBitmapHeight,
                                   fb.spectrumBitmapWidth))
    
    # You can only index/slice a Cython array after converting to a np.array
    traces = []
    for i in range(3):
        traces.append(10 * np.log10(1000 * np.asarray(
            fb.spectrumTraces[i])[:fb.spectrumTraceLength]) + 30)

    """The Cython typedef of uint8_t is an unsigned char. Because
    DPX_FrameBuffer.sogramBitmap is defined as a uint8_t*
    Python interprets, the returned value as a string. Fortunately
    Numpy has the .fromstring() method that interprets the string as
    numerical values."""
    dpxogram = np.fromstring(fb.sogramBitmap, dtype=np.uint8)
    dpxogram = dpxogram.reshape((
        fb.sogramBitmapHeight, fb.sogramBitmapWidth))[:fb.sogramBitmapNumValidLines]

    fig = plt.figure()
    ax1 = fig.add_subplot(131)
    ax1.imshow(dpxBitmap, cmap='gist_stern')
    ax1.set_aspect(7)
    ax2 = fig.add_subplot(132)
    for t in traces:
        ax2.plot(t)
    ax3 = fig.add_subplot(133)
    ax3.imshow(dpxogram, cmap='gist_stern')
    ax3.set_aspect(7)
    plt.tight_layout()
    plt.show()


def audio_demod():
    ##########################################################
    # Audio Demod
    ##########################################################
    print('\n########Audio Demod########')
    cf = 99.10e6
    refLevel = -30
    CONFIG_SetCenterFreq(cf)
    CONFIG_SetReferenceLevel(refLevel)

    cdef AudioDemodMode mode = AudioDemodMode.ADM_FM_200KHZ
    cdef float volume = 0.5
    cdef bint mute = False

    cdef int16_t data[10000]
    cdef uint16_t inSize = 10000
    cdef uint16_t outSize
    
    cdef bint enable = False

    rs = AUDIO_SetMode(mode)
    err_check(rs)

    rs = AUDIO_GetMode(&mode)
    err_check(rs)
    print('Audio Demod Mode: {}'.format(mode))

    rs = AUDIO_SetVolume(volume)
    err_check(rs)

    rs = AUDIO_GetVolume(&volume)
    err_check(rs)
    print('Audio Volume: {}'.format(volume))

    rs = AUDIO_SetMute(mute)
    err_check(rs)
    rs = AUDIO_GetMute(&mute)
    err_check(rs)
    print('Audio Mute: {}'.format(mute))

    cdef double freqOffsetHz = 0
    rs = AUDIO_SetFrequencyOffset(freqOffsetHz)
    err_check(rs)
    rs = AUDIO_GetFrequencyOffset(&freqOffsetHz)
    err_check(rs)
    print('Audio Frequency Offset: {}'.format(freqOffsetHz))

    DEVICE_Run()
    rs = AUDIO_Start()
    err_check(rs)
    rs = AUDIO_GetEnable(&enable)
    err_check(rs)
    print('Audio Enabled: {}'.format(enable))
    rs = AUDIO_GetData(data, inSize, &outSize)
    err_check(rs)
    rs = AUDIO_Stop()
    err_check(rs)
    plt.plot(data)
    plt.show()

def if_streaming():
    
    ##########################################################
    # IF Streaming
    ##########################################################
    print('\n########IF Streaming########')
    CONFIG_Preset()
    CONFIG_SetCenterFreq(2.4453e9)
    DEVICE_Run()
    
    cdef bint enable = True
    cdef bint active = True
    cdef StreamingMode mode = StreamingMode.StreamingModeFramed
    cdef char* path = 'C:\\SignalVu-PC Files\\'
    cdef char* base = 'if_stream_test'
    cdef int suffixCtl = IFSSDFN_SUFFIX_NONE
    cdef int msec = 250
    cdef int count = 1

    rs = IFSTREAM_SetDiskFileMode(mode)
    err_check(rs)
    rs = IFSTREAM_SetDiskFilePath(path)
    err_check(rs)
    rs = IFSTREAM_SetDiskFilenameBase(base)
    err_check(rs)
    rs = IFSTREAM_SetDiskFilenameSuffix(suffixCtl)
    err_check(rs)
    rs = IFSTREAM_SetDiskFileLength(msec)
    err_check(rs)
    rs = IFSTREAM_SetDiskFileCount(count)
    err_check(rs)
    print('Streaming...')
    rs = IFSTREAM_SetEnable(enable)
    err_check(rs)
    while active == 1:
        rs = IFSTREAM_GetActiveStatus(&active)
        err_check(rs)
    print('Streaming Complete.')
    print('File Location: {}{}'.format(path.decode(), base.decode()))


def iq_streaming():
    ###########################################################
    # IQ Data Streaming to Client or Disk
    ###########################################################
    print('\n########IQ Streaming########')
    CONFIG_Preset()
    CONFIG_SetCenterFreq(2.4453e9)
    DEVICE_Run()
    
    cdef double maxBandwidthHz = 0
    cdef double minBandwidthHz = 0
    cdef double bwHz_req = 20e6
    cdef double bwHz_act = 0
    cdef double srSps = 0
    cdef IQSOUTDEST dest = IQSOUTDEST.IQSOD_FILE_SIQ_SPLIT
    cdef IQSOUTDTYPE dtype = IQSOUTDTYPE.IQSODT_INT16
    cdef int reqSize = 1000
    cdef int maxSize = 0
    cdef char* filenameBase = 'C:\\SignalVu-PC Files\\iq_stream_test'
    cdef int suffixCtl = IQSSDFN_SUFFIX_NONE
    cdef int msec = 100
    
    cdef bint enable = True
    cdef void* iqdata
    cdef int iqlen = 0
    cdef IQSTRMIQINFO iqinfo
    cdef bint isComplete = False
    cdef bint isWriting = True
    cdef IQSTRMFILEINFO fileinfo
    
    rs = IQSTREAM_GetMaxAcqBandwidth(&maxBandwidthHz)
    err_check(rs)
    rs = IQSTREAM_GetMinAcqBandwidth(&minBandwidthHz)
    err_check(rs)
    print('Max Bandwidth: {}, Min Bandwidth: {}'.format(
        maxBandwidthHz, minBandwidthHz))
    
    rs = IQSTREAM_SetAcqBandwidth(bwHz_req)
    err_check(rs)
    rs = IQSTREAM_GetAcqParameters(&bwHz_act, &srSps)
    err_check(rs)
    print('IQ Bandwidth: {}, IQ Sample Rate: {}'.format(bwHz_act, srSps))
    
    rs = IQSTREAM_SetOutputConfiguration(dest, dtype)
    err_check(rs)
    rs = IQSTREAM_SetIQDataBufferSize(reqSize)
    err_check(rs)
    rs = IQSTREAM_GetIQDataBufferSize(&maxSize)
    err_check(rs)
    print('Max IQ Buffer Size: {}'.format(maxSize))
    
    rs = IQSTREAM_SetDiskFilenameBase(filenameBase)
    err_check(rs)
    rs = IQSTREAM_SetDiskFilenameSuffix(suffixCtl)
    err_check(rs)
    rs = IQSTREAM_SetDiskFileLength(msec)
    err_check(rs)

    rs = IQSTREAM_Start()
    err_check(rs)
    rs = IQSTREAM_GetEnable(&enable)
    err_check(rs)
    print('IQ Streaming Enabled: {}'.format(enable))
    while isComplete == 0:
        rs = IQSTREAM_GetDiskFileWriteStatus(&isComplete,&isWriting)
        err_check(rs)
    print('IQ Stream Complete: {}'.format(isComplete))
    rs = IQSTREAM_Stop()
    err_check(rs)
    
    # rs = IQSTREAM_GetIQData(iqdata, &iqlen, &iqinfo)
    # err_check(rs)
    rs = IQSTREAM_GetDiskFileInfo(&fileinfo)
    err_check(rs)
    # print('IQ Streaming File Info:\n{}'.format(fileinfo))
    print('Number of Samples: {}'.format(fileinfo.numberSamples))
    print('Sample 0 Timestamp: {}'.format(fileinfo.sample0Timestamp))
    print('Trigger Sample Index: {}'.format(fileinfo.triggerSampleIndex))
    print('Trigger Timestamp: {}'.format(fileinfo.triggerTimestamp))
    print('Acquisition Status: {}'.format(fileinfo.acqStatus))
    print('File Names: {} {}'.format(fileinfo.filenames[0],
                                     fileinfo.filenames[1]))
    IQSTREAM_ClearAcqStatus()


def if_playback():
    ###########################################################
    # Stored IF Data File Playback
    ###########################################################
    # THIS IS NOT WORKING YET
    print('\n########IF Playback########')
    CONFIG_Preset()
    cdef Py_UNICODE* fileName = u'C:\\SignalVu-PC Files\\if_stream_test.r3f'
    cdef int startPercentage = 0
    cdef int stopPercentage = 100
    cdef double skipTimeBetweenFullAcquisitions = 0.0
    cdef bint loopAtEndOfFile = False
    cdef bint emulateRealTime = False
    cdef bint complete = False

    print('GET READY FOR A CRASH')
    rs = PLAYBACK_OpenDiskFile(fileName, startPercentage, stopPercentage, skipTimeBetweenFullAcquisitions, loopAtEndOfFile, emulateRealTime)
    print(rs)
    err_check(rs)
    print('Opened file, beginning playback.')
    DEVICE_Run()
    rs = PLAYBACK_GetReplayComplete(&complete)
    err_check(rs)
    print('Playback complete: {}'.format(complete))
    

def gnss():
    ###########################################################
    # GNSS Rx Control and Output
    ###########################################################
    print('\n########GNSS########')
    cdef bint installed = False
    cdef bint enable = True
    GNSS_GetHwInstalled(&installed)
    cdef GNSS_SATSYS satSystem = GNSS_SATSYS.GNSS_GPS_BEIDOU
    cdef bint powered = True
    cdef int msgLen = 0
    cdef char* message
    cdef bint isValid = False
    cdef uint64_t timestamp1PPS = 0
    
    print('GNSS Hardware Installed: {}'.format(installed))
    
    GNSS_SetEnable(enable)
    GNSS_GetEnable(&enable)
    print('GNSS Enabled: {}'.format(enable))
    
    GNSS_SetSatSystem(satSystem)
    GNSS_GetSatSystem(&satSystem)
    print('GNSS Satellite System: {}'.format(satSystem))
    
    GNSS_SetAntennaPower(powered)
    GNSS_GetAntennaPower(&powered)
    print('GNSS Antenna Power: {}'.format(powered))
    
    GNSS_GetNavMessageData(&msgLen, &message)
    print('GNSS Message: {}'.format(message))
    GNSS_ClearNavMessageData()
    GNSS_Get1PPSTimestamp(&isValid, &timestamp1PPS)
    print('1PPS Timestamp Valid: {}, 1PPS Timestamp: {}'.format(
        isValid, timestamp1PPS))
    

def power_battery():
    ###########################################################
    # Power and Battery Status
    ###########################################################
    print('\n########Power and Battery########')
    cdef POWER_INFO powerInfo
    
    rs = POWER_GetStatus(&powerInfo)
    print('Power Info:\n{}'.format(powerInfo))


def test():
    cdef Py_UNICODE string[100]
    rs = DEVICE_GetNomenclatureW(string)
    err_check(rs)
    print(string)


def main():
    device_connection_info()
    device_configuration()
    trigger_configuration()
    device_alignment()
    device_operation()
    reference_time()
    dpx_acquisition()
    iq_block_data()
    spectrum_acquisition()
    audio_demod()
    if_streaming()
    iq_streaming()
    # if_playback()
    gnss()
    power_battery()

    DEVICE_Disconnect()
