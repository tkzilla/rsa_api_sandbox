cdef extern from 'RSA_API.h':
    
    ##########################################################
    # Status and Error Reporting
    ##########################################################
    
    ctypedef unsigned long long uint64_t
    
    ctypedef enum ReturnStatus:
        noError = 0

        # Connection
        errorNotConnected = 101
        errorIncompatibleFirmware = 102
        errorBootLoaderNotRunning = 103
        errorTooManyBootLoadersConnected = 104
        errorRebootFailure = 105

        # POST
        errorPOSTFailureFPGALoad = 201
        errorPOSTFailureHiPower = 202
        errorPOSTFailureI2C = 203
        errorPOSTFailureGPIF = 204
        errorPOSTFailureUsbSpeed = 205
        errorPOSTDiagFailure = 206

        # General Msmt
        errorBufferAllocFailed = 301
        errorParameter = 302
        errorDataNotReady = 304

        # Spectrum
        errorParameterTraceLength = 1101
        errorMeasurementNotEnabled = 1102
        errorSpanIsLessThanRBW = 1103
        errorFrequencyOutOfRange = 1104

        # IF streaming
        errorStreamADCToDiskFileOpen = 1201
        errorStreamADCToDiskAlreadyStreaming = 1202
        errorStreamADCToDiskBadPath = 1203
        errorStreamADCToDiskThreadFailure = 1204
        errorStreamedFileInvalidHeader = 1205
        errorStreamedFileOpenFailure = 1206
        errorStreamingOperationNotSupported = 1207
        errorStreamingFastForwardTimeInvalid = 1208
        errorStreamingInvalidParameters = 1209
        errorStreamingEOF = 1210

        # IQ streaming
        errorIQStreamInvalidFileDataType = 1301
        errorIQStreamFileOpenFailed = 1302
        errorIQStreamBandwidthOutOfRange = 1303

        # -----------------
        # Internal errors
        # -----------------
        errorTimeout = 3001
        errorTransfer = 3002
        errorFileOpen = 3003
        errorFailed = 3004
        errorCRC = 3005
        errorChangeToFlashMode = 3006
        errorChangeToRunMode = 3007
        errorDSPLError = 3008
        errorLOLockFailure = 3009
        errorExternalReferenceNotEnabled = 3010
        errorLogFailure = 3011
        errorRegisterIO = 3012
        errorFileRead = 3013

        errorDisconnectedDeviceRemoved = 3101
        errorDisconnectedDeviceNodeChangedAndRemoved = 3102
        errorDisconnectedTimeoutWaitingForADcData = 3103
        errorDisconnectedIOBeginTransfer = 3104
        errorOperationNotSupportedInSimMode = 3015

        errorFPGAConfigureFailure = 3201
        errorCalCWNormFailure = 3202
        errorSystemAppDataDirectory = 3203
        errorFileCreateMRU = 3204
        errorDeleteUnsuitableCachePath = 3205
        errorUnableToSetFilePermissions = 3206
        errorCreateCachePath = 3207
        errorCreateCachePathBoost = 3208
        errorCreateCachePathStd = 3209
        errorCreateCachePathGen = 3210
        errorBufferLengthTooSmall = 3211
        errorRemoveCachePath = 3212
        errorGetCachingDirectoryBoost = 3213
        errorGetCachingDirectoryStd = 3214
        errorGetCachingDirectoryGen = 3215
        errorInconsistentFileSystem = 3216

        errorWriteCalConfigHeader = 3301
        errorWriteCalConfigData = 3302
        errorReadCalConfigHeader = 3303
        errorReadCalConfigData = 3304
        errorEraseCalConfig = 3305
        errorCalConfigFileSize = 3306
        errorInvalidCalibConstantFileFormat = 3307
        errorMismatchCalibConstantsSize = 3308
        errorCalConfigInvalid = 3309

        # flash
        errorFlashFileSystemUnexpectedSize = 3401
        errorFlashFileSystemNotMounted = 3402
        errorFlashFileSystemOutOfRange = 3403
        errorFlashFileSystemIndexNotFound = 3404
        errorFlashFileSystemReadErrorCRC = 3405
        errorFlashFileSystemReadFileMissing = 3406
        errorFlashFileSystemCreateCacheIndex = 3407
        errorFlashFileSystemCreateCachedDataFile = 3408
        errorFlashFileSystemUnsupportedFileSize = 3409
        errorFlashFileSystemInsufficentSpace = 3410
        errorFlashFileSystemInconsistentState = 3411
        errorFlashFileSystemTooManyFiles = 3412
        errorFlashFileSystemImportFileNotFound = 3413
        errorFlashFileSystemImportFileReadError = 3414
        errorFlashFileSystemImportFileError = 3415
        errorFlashFileSystemFileNotFoundError = 3416
        errorFlashFileSystemReadBufferTooSmall = 3417
        errorFlashWriteFailure = 3418
        errorFlashReadFailure = 3419
        errorFlashFileSystemBadArgument = 3420
        errorFlashFileSystemCreateFile = 3421

        # Aux monitoring
        errorMonitoringNotSupported = 3501
        errorAuxDataNotAvailable = 3502

        # battery
        errorBatteryCommFailure = 3601
        errorBatteryChargerCommFailure = 3602
        errorBatteryNotPresent = 3603

        # EST
        errorESTOutputPathFile = 3701
        errorESTPathNotDirectory = 3702
        errorESTPathDoesntExist = 3703
        errorESTUnableToOpenLog = 3704
        errorESTUnableToOpenLimits = 3705

        # Revision information
        errorRevisionDataNotFound = 3801

        # alignment
        error112MHzAlignmentSignalLevelTooLow = 3901
        error10MHzAlignmentSignalLevelTooLow = 3902
        errorInvalidCalConstant = 3903
        errorNormalizationCacheInvalid = 3904
        errorInvalidAlignmentCache = 3905

        # acq status
        errorADCOverrange = 9000
        errorOscUnlock = 9001

        errorNotSupported = 9901

        errorPlaceholder = 9999
        notImplemented = -1

    ##########################################################
    # Global Type Definitions
    ##########################################################

    ctypedef struct Cplx32:
        float i
        float q

    ctypedef struct CplxInt32:
        int i
        int q

    ctypedef struct CplxInt16:
        int i
        int q

    # AcqDataStatus enum defined in rsa_api.pyx

    ##########################################################
    # Device Connection and Info
    ##########################################################

    const char* DEVICE_GetErrorString(ReturnStatus status)

    # DEVSRCH enum defined in rsa_api.pyx

    ReturnStatus DEVICE_Search(int* numDevicesFound, int deviceIDs[], const char deviceSerial[20][100], const char deviceType[20][20])
    # DEVICE_SearchW not imported
    #
    # DEVICE_Search() usage
    # cdef int numDevicesFound = 0
    # cdef int* deviceIDs
    # cdef char deviceSerial[DEVSRCH_MAX_NUM_DEVICES][DEVSRCH_SERIAL_MAX_STRLEN]
    # cdef char deviceType[20][20]
    #
    # rs = DEVICE_Search(&numDevicesFound, deviceIDs, deviceSerial, deviceType)
    # print('Number of devices: {}'.format(numDevicesFound))
    # print('Device serial numbers: {}'.format(deviceSerial[0].decode()))
    # print('Device type: {}'.format(deviceType[0].decode()))

    # THERE IS A PROBLEM WITH CONVERTING INT * TYPES TO PYTHON OBJECTS
    # ReturnStatus DEVICE_SearchInt(int* numDevicesFound, int* deviceIDs[], const char** deviceSerial[], const char** deviceType[])
    # DEVICE_SearchIntW not imported
    # cdef int numDevicesFound = 0
    # cdef int* deviceIDs
    # cdef char** deviceSerial
    # cdef char** deviceType
    #
    # rs = DEVICE_SearchInt(&numDevicesFound, &deviceIDs, &deviceSerial, &deviceType)
    # print('Number devices: {}'.format(numDevicesFound))
    # print('Device serial numbers: {}'.format(deviceSerial[0].decode()))
    # print('Device type: {}'.format(deviceType[0].decode()))


    ReturnStatus DEVICE_Connect(int deviceID)
    ReturnStatus DEVICE_Reset(int deviceID)
    ReturnStatus DEVICE_Disconnect()

    # DEVINFO_MAX_STRLEN defined in rsa_api.pyx
    
    ReturnStatus DEVICE_GetNomenclature(char* nomenclature)
    # ReturnStatus DEVICE_GetNomenclatureW(wchar_t * nomenclature)
    ReturnStatus DEVICE_GetSerialNumber(char* serialNum)
    ReturnStatus DEVICE_GetAPIVersion(char* apiVersion)
    ReturnStatus DEVICE_GetFWVersion(char* fwVersion)
    ReturnStatus DEVICE_GetFPGAVersion(char* fpgaVersion)
    ReturnStatus DEVICE_GetHWVersion(char* hwVersion)

    ctypedef struct DEVICE_INFO:
        char nomenclature[100]
        char serialNum[100]
        char apiVersion[100]
        char fwVersion[100]
        char fpgaVersion[100]
        char hwVersion[100]
        
    ReturnStatus DEVICE_GetInfo(DEVICE_INFO* devInfo)

    ReturnStatus DEVICE_GetOverTemperatureStatus(bint* overTemperature)

    ##########################################################
    # Device Configuration (global)
    ##########################################################

    ReturnStatus CONFIG_Preset()
    
    ReturnStatus CONFIG_SetReferenceLevel(double refLevel)
    ReturnStatus CONFIG_GetReferenceLevel(double* refLevel)
    ReturnStatus CONFIG_GetMaxCenterFreq(double* maxCF)
    ReturnStatus CONFIG_GetMinCenterFreq(double* minCF)
    ReturnStatus CONFIG_SetCenterFreq(double cf)
    ReturnStatus CONFIG_GetCenterFreq(double* cf)
    
    ReturnStatus CONFIG_SetExternalRefEnable(bint exRefEn)
    ReturnStatus CONFIG_GetExternalRefEnable(bint* exRefEn)
    ReturnStatus CONFIG_GetExternalRefFrequency(double* extFreq)
    
    ReturnStatus CONFIG_GetAutoAttenuationEnable(bint* enable)
    ReturnStatus CONFIG_SetAutoAttenuationEnable(bint enable)
    ReturnStatus CONFIG_GetRFPreampEnable(bint* enable)
    ReturnStatus CONFIG_SetRFPreampEnable(bint enable)
    ReturnStatus CONFIG_GetRFAttenuator(double* value)
    ReturnStatus CONFIG_SetRFAttenuator(double value)
    
    ##########################################################
    # Trigger Configuration
    ##########################################################
    
    ctypedef enum TriggerMode:
        freeRun = 0
        triggered = 1
        
    ctypedef enum TriggerSource:
        TriggerSourceExternal = 0
        TriggerSourceIFPowerLevel = 1
        
    ctypedef enum TriggerTransition:
        TriggerTransitionLH = 1
        TriggerTransitionHL = 2
        TriggerTransitionEither = 3
    
    ReturnStatus TRIG_SetTriggerMode(TriggerMode mode)
    ReturnStatus TRIG_GetTriggerMode(TriggerMode* mode)
    ReturnStatus TRIG_SetTriggerSource(TriggerSource source)
    ReturnStatus TRIG_GetTriggerSource(TriggerSource* source)
    ReturnStatus TRIG_SetTriggerTransition(TriggerTransition transition)
    ReturnStatus TRIG_GetTriggerTransition(TriggerTransition* transition)
    ReturnStatus TRIG_SetIFPowerTriggerLevel(double level)
    ReturnStatus TRIG_GetIFPowerTriggerLevel(double* level)
    ReturnStatus TRIG_SetTriggerPositionPercent(double trigPosPercent)
    ReturnStatus TRIG_GetTriggerPositionPercent(double* trigPosPercent)
    ReturnStatus TRIG_ForceTrigger()
    
    ##########################################################
    # Device Alignment
    ##########################################################
    
    ReturnStatus ALIGN_GetWarmupStatus(bint* warmedUp)
    ReturnStatus ALIGN_GetAlignmentNeeded(bint* needed)
    ReturnStatus ALIGN_RunAlignment()
    
    ##########################################################
    # Device Operation (global)
    ##########################################################
    
    ReturnStatus DEVICE_GetEnable(bint* enable)
    ReturnStatus DEVICE_Run()
    ReturnStatus DEVICE_Stop()
    ReturnStatus DEVICE_PrepareForRun()
    ReturnStatus DEVICE_StartFrameTransfer()
    
    # DEVEVENT enum defined in rsa_api.pyx
    
    ReturnStatus DEVICE_GetEventStatus(int eventID, bint* eventOccurred, uint64_t* eventTimestamp)
    
    ##########################################################
    # System/Reference Time
    ##########################################################
    
    ReturnStatus REFTIME_GetTimestampRate(uint64_t* o_refTimestampRate)
    ReturnStatus REFTIME_GetCurrentTime(Py_ssize_t* o_timeSec, uint64_t* o_timeNsec, uint64_t* o_timestamp)
    ReturnStatus REFTIME_GetTimeFromTimestamp(uint64_t i_timestamp, Py_ssize_t* o_timeSec, uint64_t* o_timeNsec)
    ReturnStatus REFTIME_GetTimestampFromTime(Py_ssize_t i_timeSec, uint64_t i_timeNsec, uint64_t* o_timestamp)
    ReturnStatus REFTIME_GetIntervalSinceRefTimeSet(double* sec)
    
    ReturnStatus REFTIME_SetReferenceTime(Py_ssize_t refTimeSec, uint64_t refTimeNsec, uint64_t refTimestamp)
    ReturnStatus REFTIME_GetReferenceTime(Py_ssize_t* refTimeSec, uint64_t* refTimeNsec, uint64_t* refTimestamp)
    
    ##########################################################
    # IQ Block Data aquisition
    ##########################################################
    
    ReturnStatus IQBLK_GetMaxIQBandwidth(double* maxBandwidth)
    ReturnStatus IQBLK_GetMinIQBandwidth(double* minBandwidth)
    ReturnStatus IQBLK_GetMaxIQRecordLength(int* maxSamples)
    
    ReturnStatus IQBLK_SetIQBandwidth(double iqBandwidth)
    ReturnStatus IQBLK_GetIQBandwidth(double* iqBandwidth)
    ReturnStatus IQBLK_GetIQSampleRate(double* iqSampleRate)
    ReturnStatus IQBLK_SetIQRecordLength(int recordLength)
    ReturnStatus IQBLK_GetIQRecordLength(int* recordLength)
    
    ReturnStatus IQBLK_AcquireIQData()
    ReturnStatus IQBLK_WaitForIQDataReady(int timeoutMsec, bint* ready)
    
    ReturnStatus IQBLK_GetIQData(float* iqData, int* outLength, int reqLength)
    ReturnStatus IQBLK_GetIQDataDeinterleaved(float* iData, float* qData, int* outLength, int reqLength)
    ReturnStatus IQBLK_GetIQDataCplx(Cplx32* iqData, int* outLength, int reqLength)
    
    # IQBLK_STATUS enum defined in rsa_api.pyx
    
    ctypedef struct IQBLK_ACQINFO:
        uint64_t sample0Timestamp
        uint64_t triggerSampleIndex
        uint64_t triggerTimestamp
        int acqStatus
    
    ReturnStatus IQBLK_GetIQAcqInfo(IQBLK_ACQINFO * acqInfo)
    
    ctypedef struct IQHeader:
        int acqDataStatus
        uint64_t acquisitionTimestamp
        int frameID
        int trigger1Index
        int trigger2Index
        int timeSyncIndex
    
    ReturnStatus GetIQHeader(IQHeader* header)
    
    ##########################################################
    # Spectrum Trace Acquisition
    ##########################################################
    
    ctypedef enum SpectrumWindows:
        SpectrumWindow_Kaiser = 0
        SpectrumWindow_Mil6dB = 1
        SpectrumWindow_BlackmanHarris = 2
        SpectrumWindow_Rectangle = 3
        SpectrumWindow_FlatTop = 4
        SpectrumWindow_Hann = 5
    
    ctypedef enum SpectrumTraces:
        SpectrumTrace1 = 0
        SpectrumTrace2 = 1
        SpectrumTrace3 = 2
    
    ctypedef enum SpectrumDetectors:
        SpectrumDetector_PosPeak = 0
        SpectrumDetector_NegPeak = 1
        SpectrumDetector_AverageVRMS = 2
        SpectrumDetector_Sample = 3
    
    ctypedef enum SpectrumVerticalUnits:
        SpectrumVerticalUnit_dBm = 0
        SpectrumVerticalUnit_Watt = 1
        SpectrumVerticalUnit_Volt = 2
        SpectrumVerticalUnit_Amp = 3
        SpectrumVerticalUnit_dBmV = 4
    
    # Spectrum settings structure
    # The actual values are returned from SPECTRUM_GetSettings() function
    # Use SPECTRUM_GetLimits() to get the limits of the settings
    ctypedef struct Spectrum_Settings:
        double span
        double rbw
        bint enableVBW
        double vbw
        int traceLength     # MUST be odd number
        SpectrumWindows window
        SpectrumVerticalUnits verticalUnit
    
        # additional settings return from SPECTRUM_GetSettings()
        double actualStartFreq
        double actualStopFreq
        double actualFreqStepSize
        double actualRBW
        double actualVBW
        int actualNumIQSamples
    
    ctypedef struct Spectrum_Limits:
        double maxSpan
        double minSpan
        double maxRBW
        double minRBW
        double maxVBW
        double minVBW
        int maxTraceLength
        int minTraceLength
    
    ctypedef struct Spectrum_TraceInfo:
        uint64_t timestamp       # timestamp of the first acquisition sample
        int acqDataStatus	# See AcqDataStatus enumeration for bit definitions
    
    ReturnStatus SPECTRUM_SetEnable(bint enable)
    ReturnStatus SPECTRUM_GetEnable(bint* enable)
    ReturnStatus SPECTRUM_SetDefault()
    ReturnStatus SPECTRUM_SetSettings(Spectrum_Settings settings)
    ReturnStatus SPECTRUM_GetSettings(Spectrum_Settings* settings)
    ReturnStatus SPECTRUM_SetTraceType(SpectrumTraces trace, bint enable, SpectrumDetectors detector)
    ReturnStatus SPECTRUM_GetTraceType(SpectrumTraces trace, bint* enable, SpectrumDetectors* detector)
    ReturnStatus SPECTRUM_GetLimits(Spectrum_Limits* limits)
    
    ReturnStatus SPECTRUM_AcquireTrace()
    ReturnStatus SPECTRUM_WaitForTraceReady(int timeoutMsec, bint* ready)
    
    ReturnStatus SPECTRUM_GetTrace(SpectrumTraces trace, int maxTracePoints, float* traceData, int* outTracePoints)
    ReturnStatus SPECTRUM_GetTraceInfo(Spectrum_TraceInfo* traceInfo)
    
    ##########################################################
    # DPX Bitmap, Trace, and Spectrogram
    ##########################################################


# DEVICE_SearchInt usage
    # cdef int numDevicesFound = 0
    # cdef int* deviceIDs
    # cdef char** deviceSerial
    # cdef char** deviceType

    # rs = DEVICE_SearchInt(&numDevicesFound, &deviceIDs, &deviceSerial, &deviceType)
    # print('Number of devices: {}'.format(numDevicesFound))
    # print('Device serial numbers: {}'.format(deviceSerial[0]))
    # print('Device type: {}'.format(deviceType[0]))


    #
    # class DEVICE_INFO(Structure):
    #     _fields_ = c_int([('nomenclature', c_char_p),
    #                 ('serialNum', c_char_p),
    #                 ('apiVersion', c_char_p),
    #                 ('fwVersion', c_char_p),
    #                 ('fpgaVersion', c_char_p),
    #                 ('hwVersion', c_char_p)]
    #
    # class TriggerMode:
    #     def __init__(self):
    #         self.freeRun = c_int(c_int(0)
    #         self.triggered = c_int(c_int(1)
    #
    # TriggerMode = c_int(TriggerMode()
    #
    # class TriggerSource:
    #     def __init__(self):
    #         self.TriggerSourceExternal = c_int(c_int(0)
    #         self.TriggerSourceIFPowerLevel = c_int(c_int(1)
    #
    # TriggerSource = c_int(TriggerSource()
    #
    # class TriggerTransition:
    #     def __init__(self):
    #         self.TriggerTransitionLH = c_int(c_int(1)
    #         self.TriggerTransitionHL = c_int(c_int(2)
    #         self.TriggerTransitionEither = c_int(c_int(3)
    #
    # TriggerTransition = c_int(TriggerTransition()
    #
    # DEVEVENT_OVERRANGE = c_int(c_int(0)
    # DEVEVENT_TRIGGER = c_int(c_int(1)
    # DEVEVENT_1PPS = c_int(c_int(2)
    #
    # class RunMode:
    #     def __init__(self):
    #         self.stopped = c_int(c_int(0)
    #         self.running = c_int(c_int(1)
    #
    # RunMode = c_int(RunMode()
    #
    # IQBLK_STATUS_INPUT_OVERRANGE = c_int((1 << 0)
    # IQBLK_STATUS_FREQREF_UNLOCKED = c_int((1 << 1)
    # IQBLK_STATUS_ACQ_SYS_ERROR = c_int((1 << 2)
    # IQBLK_STATUS_DATA_XFER_ERROR = c_int((1 << 3)
    #
    # class IQBLK_ACQINFO(Structure):
    #     _fields_ = c_int([('sample0Timestamp', c_uint64),
    #                 ('triggerSampleIndex', c_uint64),
    #                 ('triggerTimestamp', c_uint64),
    #                 ('acqStatus', c_uint32)]
    #
    # class IQHeader(Structure):
    #     _fields_ = c_int([('acqDataStatus', c_uint16),
    #                 ('acquisitionTimestamp', c_uint64),
    #                 ('frameID', c_uint32),
    #                 ('trigger1Index', c_uint16),
    #                 ('trigger2Index', c_uint16),
    #                 ('timeSyncIndex', c_uint16)]
    #
    # class SpectrumWindows:
    #     def __init__(self):
    #         self.SpectrumWindow_Kaiser = c_int(c_int(0)
    #         self.SpectrumWindow_Mil6dB = c_int(c_int(1)
    #         self.SpectrumWindow_BlackmanHarris = c_int(c_int(2)
    #         self.SpectrumWindow_Rectangle = c_int(c_int(3)
    #         self.SpectrumWindow_FlatTop = c_int(c_int(4)
    #         self.SpectrumWindow_Hann = c_int(c_int(5)
    #
    # SpectrumWindows = c_int(SpectrumWindows()
    #
    # class SpectrumTraces:
    #     def __init__(self):
    #         self.SpectrumTrace1 = c_int(c_int(0)
    #         self.SpectrumTrace2 = c_int(c_int(1)
    #         self.SpectrumTrace3 = c_int(c_int(2)
    #
    # SpectrumTraces = c_int(SpectrumTraces()
    #
    # class SpectrumDetectors:
    #     def __init__(self):
    #         self.SpectrumDetector_PosPeak = c_int(c_int(0)
    #         self.SpectrumDetector_NegPeak = c_int(c_int(1)
    #         self.SpectrumDetector_AverageVRMS = c_int(c_int(2)
    #         self.SpectrumDetector_Sample = c_int(c_int(3)
    #
    # SpectrumDetectors = c_int(SpectrumDetectors()
    #
    # class SpectrumVerticalUnits:
    #     def __init__(self):
    #         self.SpectrumVerticalUnit_dBm = c_int(c_int(0)
    #         self.SpectrumVerticalUnit_Watt = c_int(c_int(1)
    #         self.SpectrumVerticalUnit_Volt = c_int(c_int(2)
    #         self.SpectrumVerticalUnit_Amp = c_int(c_int(3)
    #         self.SpectrumVerticalUnit_dBmV = c_int(c_int(4)
    #
    # SpectrumVerticalUnits = c_int(SpectrumVerticalUnits()
    #
    # class Spectrum_Settings(Structure):
    #     _fields_ = c_int([('span', c_double),
    #                 ('rbw', c_double),
    #                 ('enableVBW', c_bint),
    #                 ('vbw', c_double),
    #                 ('traceLength', c_int),
    #                 ('window', c_int),
    #                 ('verticalUnit', c_int),
    #                 ('actualStartFreq', c_double),
    #                 ('actualStopFreq', c_double),
    #                 ('actualFreqStepSize', c_double),
    #                 ('actualRBW', c_double),
    #                 ('actualVBW', c_double),
    #                 ('actualNumIQSamples', c_double)]
    #
    # class Spectrum_Limits(Structure):
    #     _fields_ = c_int([('maxSpan', c_double),
    #                 ('minSpan', c_double),
    #                 ('maxRBW', c_double),
    #                 ('minRBW', c_double),
    #                 ('maxVBW', c_double),
    #                 ('minVBW', c_double),
    #                 ('maxTraceLength', c_int),
    #                 ('minTraceLength', c_int)]
    #
    # class Spectrum_TraceInfo(Structure):
    #     _fields_ = c_int([('timestamp', c_int64),
    #                 ('acqDataStatus', c_uint16)]
    #
    # class DPX_FrameBuffer(Structure):
    #     _fields_ = c_int([('fftPerFrame', c_int32),
    #                 ('fftCount', c_int64),
    #                 ('frameCount', c_int64),
    #                 ('timestamp', c_double),
    #                 ('acqDataStatus', c_uint32),
    #                 ('minSigDuration', c_double),
    #                 ('minSigDurOutOfRange', c_bint),
    #                 ('spectrumBitmapWidth', c_int32),
    #                 ('spectrumBitmapHeight', c_int32),
    #                 ('spectrumBitmapSize', c_int32),
    #                 ('spectrumTraceLength', c_int32),
    #                 ('numSpectrumTraces', c_int32),
    #                 ('spectrumEnabled', c_bint),
    #                 ('spectrogramEnabled', c_bint),
    #                 ('spectrumBitmap', POINTER(c_float)),
    #                 ('spectrumTraces', POINTER(POINTER(c_float))),
    #                 ('sogramBitmapWidth', c_int32),
    #                 ('sogramBitmapHeight', c_int32),
    #                 ('sogramBitmapSize', c_int32),
    #                 ('sogramBitmapNumValidLines', c_int32),
    #                 ('sogramBitmap', POINTER(c_uint8)),
    #                 ('sogramBitmapTimestampArray', POINTER(c_double)),
    #                 ('sogramBitmapContainTriggerArray', POINTER(c_double))]
    #
    # class DPX_SogramSettingStruct(Structure):
    #     _fields_ = c_int([('bitmapWidth', c_int32),
    #                 ('bitmapHeight', c_int32),
    #                 ('sogramTraceLineTime', c_double),
    #                 ('sogramBitmapLineTime', c_double)]
    #
    # class DPX_SettingStruct(Structure):
    #     _fields_ = c_int([('enableSpectrum', c_bint),
    #                 ('enableSpectrogram', c_bint),
    #                 ('bitmapWidth', c_int32),
    #                 ('bitmapHeight', c_int32),
    #                 ('traceLength', c_int32),
    #                 ('decayFactor', c_float),
    #                 ('actualRBW', c_double)]
    #
    # class TraceType:
    #     def __init__(self):
    #         self.TraceTypeAverage = c_int(c_int(0)
    #         self.TraceTypeMax = c_int(c_int(1)
    #         self.TraceTypeMaxHold = c_int(c_int(2)
    #         self.TraceTypeMin = c_int(c_int(3)
    #         self.TraceTypeMinHold = c_int(c_int(4)
    #
    # TraceType = c_int(TraceType()
    #
    # class VerticalUnitType:
    #     def __init__(self):
    #         self.VerticalUnit_dBm = c_int(c_int(0)
    #         self.VerticalUnit_Watt = c_int(c_int(1)
    #         self.VerticalUnit_Volt = c_int(c_int(2)
    #         self.VerticalUnit_Amp = c_int(c_int(3)
    #
    # VerticalUnitType = c_int(VerticalUnitType()
    #
    # DPX_TRACEIDX_1 = c_int(c_int(0)
    # DPX_TRACEIDX_2 = c_int(c_int(1)
    # DPX_TRACEIDX_3 = c_int(c_int(2)
    #
    # class AudioDemodMode:
    #     def __init__(self):
    #         self.ADM_FM_8KHZ = c_int(c_int(0)
    #         self.ADM_FM_13KHZ = c_int(c_int(1)
    #         self.ADM_FM_75KHZ = c_int(c_int(2)
    #         self.ADM_FM_200KHZ = c_int(c_int(3)
    #         self.ADM_AM_8KHZ = c_int(c_int(4)
    #         self.ADM_NONE = c_int(c_int(5)  # internal use only
    #
    # AudioDemodMode = c_int(AudioDemodMode()
    #
    # class StreamingMode:
    #     def __init__(self):
    #         self.StreamingModeRaw = c_int(c_int(0)
    #         self.StreamingModeFormatted = c_int(c_int(1)
    #
    # StreamingMode = c_int(StreamingMode()
    #
    # class IQSOUTDEST:
    #     def __init__(self):
    #         self.IQSOD_CLIENT = c_int(c_int(0)
    #         self.IQSOD_FILE_TIQ = c_int(c_int(1)
    #         self.IQSOD_FILE_SIQ = c_int(c_int(2)
    #         self.IQSOD_FILE_SIQ_SPLIT = c_int(c_int(3)
    #
    # IQSOUTDEST = c_int(IQSOUTDEST()
    #
    # class IQSOUTDTYPE:
    #     def __init__(self):
    #         self.IQSODT_SINGLE = c_int(c_int(0)
    #         self.IQSODT_INT32 = c_int(c_int(1)
    #         self.IQSODT_INT16 = c_int(c_int(2)
    #
    # IQSOUTDTYPE = c_int(IQSOUTDTYPE()
    #
    # IQSSDFN_SUFFIX_INCRINDEX_MIN = c_int(c_int(0)
    # IQSSDFN_SUFFIX_TIMESTAMP = c_int(c_int(-1)
    # IQSSDFN_SUFFIX_NONE = c_int(c_int(-2)
    #
    # IFSSDFN_SUFFIX_INCRINDEX_MIN = c_int(c_int(0)
    # IFSSDFN_SUFFIX_TIMESTAMP = c_int(c_int(-1)
    # IFSSDFN_SUFFIX_NONE = c_int(c_int(-2)
    #
    # IQSTRM_STATUS_OVERRANGE = c_int((1 << 0)
    # IQSTRM_STATUS_XFER_DISCONTINUITY = c_int((1 << 1)
    # IQSTRM_STATUS_IBUFF75PCT = c_int((1 << 2)
    # IQSTRM_STATUS_IBUFFOVFLOW = c_int((1 << 3)
    # IQSTRM_STATUS_OBUFF75PCT = c_int((1 << 4)
    # IQSTRM_STATUS_OBUFFOVFLOW = c_int((1 << 5)
    # IQSTRM_STATUS_NONSTICKY_SHIFT = c_int(0
    # IQSTRM_STATUS_STICKY_SHIFT = c_int(16
    #
    # IQSTRM_MAXTRIGGERS = c_int(100
    #
    # class IQSTRMIQINFO(Structure):
    #     _fields_ = c_int([('timestamp', c_uint64),
    #                 ('triggerCount', c_int),
    #                 ('triggerIndices', POINTER(c_int)),
    #                 ('scaleFactor', c_double),
    #                 ('acqStatus', c_uint32)]
    #
    # class IQSTREAM_File_Info(Structure):
    #     _fields_ = c_int([('numberSamples', c_uint64),
    #                 ('sample0Timestamp', c_uint64),
    #                 ('triggerSampleIndex', c_uint64),
    #                 ('triggerTimestamp', c_uint64),
    #                 ('acqStatus', c_uint32),
    #                 ('filenames', c_wchar_p)]
    #
    # class GNSS_SATSYS:
    #     def __init__(self):
    #         self.GNSS_NOSYS = c_int(c_int(0)
    #         self.GNSS_GPS_GLONASS = c_int(c_int(1)
    #         self.GNSS_GPS_BEIDOU = c_int(c_int(2)
    #         self.GNSS_GPS = c_int(c_int(3)
    #         self.GNSS_GLONASS = c_int(c_int(4)
    #         self.GNSS_BEIDOU = c_int(c_int(5)
    #
    # GNSS_SATSYS = c_int(GNSS_SATSYS()
    #
    # class POWER_INFO(Structure):
    #     _fields_ = c_int([('externalPowerPresent', c_bint),
    #                 ('batteryPresent', c_bint),
    #                 ('batteryChargeLevel', c_double),
    #                 ('batteryCharging', c_bint),
    #                 ('batteryOverTemperature', c_bint),
    #                 ('batteryHardwareError', c_bint)]
    #
