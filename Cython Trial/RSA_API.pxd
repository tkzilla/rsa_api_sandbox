# RSA_API.pxd
cdef extern from 'C:\\Tektronix\\RSA_API\\include\\RSA_API.h':
    int DEVICE_Connect(int deviceID);
    int DEVICE_GetAPIVersion(char* apiVersion);


"""
/**************************************************************************************************
*  RSA_API.h -- RSA API SW interface definition for RSA306/50x/60x devices (AKA "V2") 
*
*  Backward compatibility for the initial RSA300_API interface is supported by
*  by defining the macro value RSA300_API_LEGACY before including this file.
*  This is done within the RSA300API.h file to support user legacy applications.
*
* --- RSA300_API (V1) is DEPRECATED and support will be removed in later releases.
* --- API users are strongly encouraged to migrate their applications to the
* --- RSA_API (V2) API definition in this file.
*
*  Copyright (c) Tektronix Incorporated 2015.  All rights reserved.
*  Licensed software products are owned by Tektronix or its subsidiaries or suppliers,
*  and are protected by national copyright laws and international treaty provisions.
***************************************************************************************************/

#ifndef RSA_API_H
#define RSA_API_H

// --- Select RSA_API (V2) or RSA300_API (V1) compatibility
#ifdef RSA300_API_LEGACY    
#define IS_RSA300_API   // AKA "V1"
#define __NAMESPACE_API__  RSA300_API
#define RSA300_API_DLL __declspec(dllexport)
#define RSA_API_DLL RSA300_API_DLL
#else
#define IS_RSA_API      // AKA "V2"
#define __NAMESPACE_API__  RSA_API
#define RSA_API_DLL __declspec(dllexport)
#endif

#include <stdint.h>

#ifdef __cplusplus
namespace __NAMESPACE_API__
{
extern "C"
{
#endif //__cplusplus

    ///////////////////////////////////////////////////////////
    // Status and Error Reporting
    ///////////////////////////////////////////////////////////
    // Note: The assigned enumeration values in this list have
    //        been modified between V1 and V2 releases.
    ///////////////////////////////////////////////////////////

    typedef enum
    {
        //-----------------
        // User errors
        //-----------------

        noError = 0,

        // Connection
        errorNotConnected = 101,
        errorIncompatibleFirmware,
        errorBootLoaderNotRunning,
        errorTooManyBootLoadersConnected,
        errorRebootFailure,

        // POST
        errorPOSTFailureFPGALoad = 201,
        errorPOSTFailureHiPower,
        errorPOSTFailureI2C,
        errorPOSTFailureGPIF,
        errorPOSTFailureUsbSpeed,
        errorPOSTDiagFailure,

        // General Msmt
        errorBufferAllocFailed = 301,
        errorParameter,
        errorDataNotReady,

        // Spectrum
        errorParameterTraceLength = 1101,
        errorMeasurementNotEnabled,
        errorSpanIsLessThanRBW,
        errorFrequencyOutOfRange,

        // IF streaming
        errorStreamADCToDiskFileOpen = 1201,
        errorStreamADCToDiskAlreadyStreaming,
        errorStreamADCToDiskBadPath,
        errorStreamADCToDiskThreadFailure,
        errorStreamedFileInvalidHeader,
        errorStreamedFileOpenFailure,
        errorStreamingOperationNotSupported,
        errorStreamingFastForwardTimeInvalid,
        errorStreamingInvalidParameters,
        errorStreamingEOF,

        // IQ streaming
        errorIQStreamInvalidFileDataType = 1301,
        errorIQStreamFileOpenFailed,
        errorIQStreamBandwidthOutOfRange,


        //-----------------
        // Internal errors
        //-----------------
        errorTimeout = 3001,
        errorTransfer,
        errorFileOpen,
        errorFailed,
        errorCRC,
        errorChangeToFlashMode,
        errorChangeToRunMode,
        errorDSPLError,
        errorLOLockFailure,
        errorExternalReferenceNotEnabled,
        errorLogFailure,
        errorRegisterIO,
        errorFileRead,

        errorDisconnectedDeviceRemoved = 3101,
        errorDisconnectedDeviceNodeChangedAndRemoved,
        errorDisconnectedTimeoutWaitingForADcData,
        errorDisconnectedIOBeginTransfer,
        errorOperationNotSupportedInSimMode,

        errorFPGAConfigureFailure = 3201,
        errorCalCWNormFailure,
        errorSystemAppDataDirectory,
        errorFileCreateMRU,
        errorDeleteUnsuitableCachePath,
        errorUnableToSetFilePermissions,
        errorCreateCachePath,
        errorCreateCachePathBoost,
        errorCreateCachePathStd,
        errorCreateCachePathGen,
        errorBufferLengthTooSmall,
        errorRemoveCachePath,
        errorGetCachingDirectoryBoost,
        errorGetCachingDirectoryStd,
        errorGetCachingDirectoryGen,
        errorInconsistentFileSystem,

        errorWriteCalConfigHeader = 3301,
        errorWriteCalConfigData,
        errorReadCalConfigHeader,
        errorReadCalConfigData,
        errorEraseCalConfig,
        errorCalConfigFileSize,
        errorInvalidCalibConstantFileFormat,
        errorMismatchCalibConstantsSize,
        errorCalConfigInvalid,

        // flash
        errorFlashFileSystemUnexpectedSize = 3401,
        errorFlashFileSystemNotMounted,
        errorFlashFileSystemOutOfRange,
        errorFlashFileSystemIndexNotFound,
        errorFlashFileSystemReadErrorCRC,
        errorFlashFileSystemReadFileMissing,
        errorFlashFileSystemCreateCacheIndex,
        errorFlashFileSystemCreateCachedDataFile,
        errorFlashFileSystemUnsupportedFileSize,
        errorFlashFileSystemInsufficentSpace,
        errorFlashFileSystemInconsistentState,
        errorFlashFileSystemTooManyFiles,
        errorFlashFileSystemImportFileNotFound,
        errorFlashFileSystemImportFileReadError,
        errorFlashFileSystemImportFileError,
        errorFlashFileSystemFileNotFoundError,
        errorFlashFileSystemReadBufferTooSmall,
        errorFlashWriteFailure,
        errorFlashReadFailure,
        errorFlashFileSystemBadArgument,
        errorFlashFileSystemCreateFile,

        // Aux monitoring
        errorMonitoringNotSupported = 3501,
        errorAuxDataNotAvailable,

        // battery
        errorBatteryCommFailure = 3601,
        errorBatteryChargerCommFailure = 3602,
        errorBatteryNotPresent = 3603,

        //EST
        errorESTOutputPathFile = 3701,
        errorESTPathNotDirectory,
        errorESTPathDoesntExist,
        errorESTUnableToOpenLog,
        errorESTUnableToOpenLimits,

        // Revision information
        errorRevisionDataNotFound = 3801,
        
        //  alignment
        error112MHzAlignmentSignalLevelTooLow = 3901,
        error10MHzAlignmentSignalLevelTooLow,
        errorInvalidCalConstant,
        errorNormalizationCacheInvalid,
        errorInvalidAlignmentCache,

        // acq status
        errorADCOverrange = 9000,   // must not change the location of these error codes without coordinating with MFG TEST
        errorOscUnlock = 9001,      

        errorNotSupported = 9901,

        errorPlaceholder = 9999,
        notImplemented = -1

    } ReturnStatus;


    ///////////////////////////////////////////////////////////
    // Global Type Definitions
    ///////////////////////////////////////////////////////////

#ifndef __cplusplus
    // Create a bool type for "plain" C
    typedef uint8_t bool;       
    #ifndef false
        #define false (0)
    #endif
    #ifndef true 
        #define true (1)
    #endif
#endif

    // Complex data type definitions
    typedef struct
    {
        float i;
        float q;
    } Cplx32;
    typedef struct
    {
        int32_t i;
        int32_t q;
    } CplxInt32;
    typedef struct
    {
        int16_t i;
        int16_t q;
    } CplxInt16;


    //
    // AcqDataStatus enumeration gives the bit-field defininitions for the .acqDataStatus member in the following info structs:
    //   * IQHeader (returned by GetIQHeader() (RSA300_API (V1) version only))
    //   * Spectrum_TraceInfo( returned by SPECTRUM_GetTraceInfo())
    //   * DPX_FrameBuffer (returned by DPX_GetFrameBuffer())
    //  NOTE: Any active (1) bits in the status word other than defined below are for internal use only and should be ignored.
    //
#ifdef IS_RSA_API  // V2-only content 
    enum
    { 
        AcqDataStatus_ADC_OVERRANGE     = 0x1,      // Bit 0: Overrange - Input to the ADC was outside of its operating range.
        AcqDataStatus_REF_OSC_UNLOCK    = 0x2,      // Bit 1: RefOscUnlocked - Loss of locked status on the reference oscillator.
        AcqDataStatus_LOW_SUPPLY_VOLTAGE = 0x10,    // Bit 4: PowerFail - Power (5V and Usb) failure detected.
        AcqDataStatus_ADC_DATA_LOST     = 0x20,     // Bit 5: Dropped frame - Loss of ADC data frame samples
        AcqDataStatus_VALID_BITS_MASK   = (AcqDataStatus_ADC_OVERRANGE | AcqDataStatus_REF_OSC_UNLOCK | AcqDataStatus_LOW_SUPPLY_VOLTAGE | AcqDataStatus_ADC_DATA_LOST)
    };  // AcqDataStatus
#else  // IS_RSA300_API -- Legacy support - OBSOLETE, do not use for new work
    typedef enum
    {
        adcOverrange = 0x1,             // Bit 0: Overrange - Input to the ADC was outside of its operating range.
        refFreqUnlock = 0x2,            // Bit 1: Reference oscillator unlocked - Loss of locked status on the reference oscillator.
        lo1Unlock = 0x4,                // Bit 2: Internal use only
        lo2Unlock = 0x8,                // Bit 3: Internal use only
        lowSupplyVoltage = 0x10,        // Bit 4: Power fail - Power (5V and Usb) failure detected.
        adcDataLost = 0x20,             // Bit 5: Dropped frame - Loss of ADC data frame samples
        event1pps = 0x40,               // Bit 6: Internal use only
        eventTrig1 = 0x80,              // Bit 7: Internal use only
        eventTrig2 = 0x100,             // Bit 8: Internal use only
    } AcqDataStatus;
#endif

    ///////////////////////////////////////////////////////////
    // Device Connection and Info
    ///////////////////////////////////////////////////////////

#ifdef IS_RSA_API  // V2-only content 

    RSA_API_DLL const char*  DEVICE_GetErrorString(ReturnStatus status);        // translate ReturnStatus code into text (char) string

    // Device Search maximum sizes:
    enum { DEVSRCH_MAX_NUM_DEVICES = 20, DEVSRCH_SERIAL_MAX_STRLEN = 100, DEVSRCH_TYPE_MAX_STRLEN = 20 };

    // Device Search, Type 1 (Client provides storage buffers)
    // Example: 
    // int numDev;
    // int devID[RSA_API::DEVSRCH_MAX_NUM_DEVICES];
    // {char|wchar_t} devSN[RSA_API::DEVSRCH_MAX_NUM_DEVICES][RSA_API::DEVSRCH_SERIAL_MAX_STRLEN];
    // {char|wchar_t} devType[RSA_API::DEVSRCH_MAX_NUM_DEVICES][RSA_API::DEVSRCH_TYPE_MAX_STRLEN];
    // rs = RSA_API::DEVICE_Search{W}(&numDev, devID, devSN, devType);
    RSA_API_DLL ReturnStatus DEVICE_Search(int* numDevicesFound, int deviceIDs[], char deviceSerial[][DEVSRCH_SERIAL_MAX_STRLEN], char deviceType[][DEVSRCH_TYPE_MAX_STRLEN]);
    RSA_API_DLL ReturnStatus DEVICE_SearchW(int* numDevicesFound, int deviceIDs[], wchar_t deviceSerial[][DEVSRCH_SERIAL_MAX_STRLEN], wchar_t deviceType[][DEVSRCH_TYPE_MAX_STRLEN]);   
    
    // Device Search, Type 2 (API provides internal static storage buffers, client may copy if needed)
    // Example: 
    // int numDev;
    // int* devID;                      // ptr to devID array
    // const {char|wchar_t}** devSN;    // ptr to array of ptrs to devSN strings
    // const {char|wchar_t}** devType;  // ptr to array of ptrs to devType strings
    // rs = RSA_API::DEVICE_SearchInt{W}(&numDev, &devID, &devSN, &devType);
    RSA_API_DLL ReturnStatus DEVICE_SearchInt(int* numDevicesFound, int* deviceIDs[], const char** deviceSerial[], const char** deviceType[]);
    RSA_API_DLL ReturnStatus DEVICE_SearchIntW(int* numDevicesFound, int* deviceIDs[], const wchar_t** deviceSerial[], const wchar_t** deviceType[]);

    RSA_API_DLL ReturnStatus DEVICE_Connect(int deviceID);
    RSA_API_DLL ReturnStatus DEVICE_Reset(int deviceID);
    RSA_API_DLL ReturnStatus DEVICE_Disconnect();

    // Version Info of connected device
    // Example:  char xyzInfo[DEVINFO_MAX_STRLEN];  DEVICE_Get<xyz>Version(xyzInfo);
    enum { DEVINFO_MAX_STRLEN = 100 };
    RSA_API_DLL ReturnStatus DEVICE_GetNomenclature(char* nomenclature);
    RSA_API_DLL ReturnStatus DEVICE_GetNomenclatureW(wchar_t* nomenclature);
    RSA_API_DLL ReturnStatus DEVICE_GetSerialNumber(char* serialNum);
    RSA_API_DLL ReturnStatus DEVICE_GetAPIVersion(char* apiVersion);
    RSA_API_DLL ReturnStatus DEVICE_GetFWVersion(char* fwVersion);
    RSA_API_DLL ReturnStatus DEVICE_GetFPGAVersion(char* fpgaVersion);
    RSA_API_DLL ReturnStatus DEVICE_GetHWVersion(char* hwVersion);
    // Get all device info strings at once
    typedef struct
    {
        char nomenclature[DEVINFO_MAX_STRLEN];
        char serialNum[DEVINFO_MAX_STRLEN];
        char apiVersion[DEVINFO_MAX_STRLEN];
        char fwVersion[DEVINFO_MAX_STRLEN];
        char fpgaVersion[DEVINFO_MAX_STRLEN];
        char hwVersion[DEVINFO_MAX_STRLEN];
    } DEVICE_INFO;
    RSA_API_DLL ReturnStatus DEVICE_GetInfo(DEVICE_INFO* devInfo);
    
    RSA_API_DLL ReturnStatus DEVICE_GetOverTemperatureStatus(bool* overTemperature);

#else // IS_RSA300_API -- Legacy support
    RSA300_API_DLL const char* GetErrorString(ReturnStatus status);
    RSA300_API_DLL ReturnStatus Search(long deviceIDs[], wchar_t* deviceSerial[], int* numDevicesFound); //returns array of valid deviceIDs
    RSA300_API_DLL ReturnStatus Connect(long deviceID); //connect to specific deviceID
    RSA300_API_DLL ReturnStatus ResetDevice(long deviceID);
    RSA300_API_DLL ReturnStatus Disconnect();
    RSA300_API_DLL ReturnStatus GetAPIVersion(char* apiVersion);
    RSA300_API_DLL ReturnStatus GetFirmwareVersion(char* fwVersion);
    RSA300_API_DLL ReturnStatus GetFPGAVersion(char* fpgaVersion);
    RSA300_API_DLL ReturnStatus GetHWVersion(char* hwVersion);
    RSA300_API_DLL ReturnStatus GetDeviceSerialNumber(char* serialNum);
    RSA300_API_DLL ReturnStatus GetDeviceNomenclature(char* nomenclature);
    RSA300_API_DLL ReturnStatus POST_QueryStatus();
#endif 
    
    ///////////////////////////////////////////////////////////
    // Device Configuration (global)
    ///////////////////////////////////////////////////////////

#ifdef IS_RSA_API  // V2-only content 
    RSA_API_DLL ReturnStatus CONFIG_Preset();

    RSA_API_DLL ReturnStatus CONFIG_SetReferenceLevel(double refLevel);
    RSA_API_DLL ReturnStatus CONFIG_GetReferenceLevel(double* refLevel);
    RSA_API_DLL ReturnStatus CONFIG_GetMaxCenterFreq(double* maxCF);
    RSA_API_DLL ReturnStatus CONFIG_GetMinCenterFreq(double* minCF);
    RSA_API_DLL ReturnStatus CONFIG_SetCenterFreq(double cf);
    RSA_API_DLL ReturnStatus CONFIG_GetCenterFreq(double* cf);

    RSA_API_DLL ReturnStatus CONFIG_SetExternalRefEnable(bool exRefEn);
    RSA_API_DLL ReturnStatus CONFIG_GetExternalRefEnable(bool* exRefEn);
    RSA_API_DLL ReturnStatus CONFIG_GetExternalRefFrequency(double* extFreq);

    RSA_API_DLL ReturnStatus CONFIG_GetAutoAttenuationEnable(bool *enable);
    RSA_API_DLL ReturnStatus CONFIG_SetAutoAttenuationEnable(bool enable);
    RSA_API_DLL ReturnStatus CONFIG_GetRFPreampEnable(bool *enable);
    RSA_API_DLL ReturnStatus CONFIG_SetRFPreampEnable(bool enable);
    RSA_API_DLL ReturnStatus CONFIG_GetRFAttenuator(double *value);
    RSA_API_DLL ReturnStatus CONFIG_SetRFAttenuator(double value);

#else // IS_RSA300_API -- Legacy support
    RSA300_API_DLL ReturnStatus Preset();

    RSA300_API_DLL ReturnStatus SetReferenceLevel(double refLevel);
    RSA300_API_DLL ReturnStatus GetReferenceLevel(double* refLevel);
    RSA300_API_DLL ReturnStatus GetMaxCenterFreq(double* maxCF);
    RSA300_API_DLL ReturnStatus GetMinCenterFreq(double* minCF);
    RSA300_API_DLL ReturnStatus SetCenterFreq(double cf);
    RSA300_API_DLL ReturnStatus GetCenterFreq(double* cf);
    RSA300_API_DLL ReturnStatus GetTunedCenterFreq(double* cf);
    RSA300_API_DLL ReturnStatus SetExternalRefEnable(bool exRefEn);
    RSA300_API_DLL ReturnStatus GetExternalRefEnable(bool* exRefEn);
#endif 


    ///////////////////////////////////////////////////////////
    // Trigger Configuration 
    ///////////////////////////////////////////////////////////
    
    typedef enum
    {
        freeRun = 0,
        triggered = 1
    } TriggerMode;

    typedef enum
    {
        TriggerSourceExternal = 0,      //  external 
        TriggerSourceIFPowerLevel = 1   //  IF power level
    } TriggerSource;

    typedef enum
    {
        TriggerTransitionLH = 1,        //  Low to High transition      
        TriggerTransitionHL = 2,        //  High to Low transition
        TriggerTransitionEither = 3     //  either Low to High or High to Low transition    
    } TriggerTransition;

#ifdef IS_RSA_API  // V2-only content 
    RSA_API_DLL ReturnStatus TRIG_SetTriggerMode(TriggerMode mode);
    RSA_API_DLL ReturnStatus TRIG_GetTriggerMode(TriggerMode* mode);
    RSA_API_DLL ReturnStatus TRIG_SetTriggerSource(TriggerSource source);
    RSA_API_DLL ReturnStatus TRIG_GetTriggerSource(TriggerSource *source);
    RSA_API_DLL ReturnStatus TRIG_SetTriggerTransition(TriggerTransition transition);
    RSA_API_DLL ReturnStatus TRIG_GetTriggerTransition(TriggerTransition *transition);
    RSA_API_DLL ReturnStatus TRIG_SetIFPowerTriggerLevel(double level);
    RSA_API_DLL ReturnStatus TRIG_GetIFPowerTriggerLevel(double *level);
    RSA_API_DLL ReturnStatus TRIG_SetTriggerPositionPercent(double trigPosPercent);
    RSA_API_DLL ReturnStatus TRIG_GetTriggerPositionPercent(double* trigPosPercent);
    RSA_API_DLL ReturnStatus TRIG_ForceTrigger();
#else // IS_RSA300_API -- Legacy support
    RSA300_API_DLL ReturnStatus ForceTrigger();
    RSA300_API_DLL ReturnStatus SetTriggerPositionPercent(double trigPosPercent);
    RSA300_API_DLL ReturnStatus GetTriggerPositionPercent(double* trigPosPercent);
    RSA300_API_DLL ReturnStatus SetTriggerMode(TriggerMode mode);
    RSA300_API_DLL ReturnStatus GetTriggerMode(TriggerMode* mode);
    RSA300_API_DLL ReturnStatus SetTriggerTransition(TriggerTransition transition);
    RSA300_API_DLL ReturnStatus GetTriggerTransition(TriggerTransition *transition);
    RSA300_API_DLL ReturnStatus SetTriggerSource(TriggerSource source);
    RSA300_API_DLL ReturnStatus GetTriggerSource(TriggerSource *source);
    RSA300_API_DLL ReturnStatus SetIFPowerTriggerLevel(double level);
    RSA300_API_DLL ReturnStatus GetIFPowerTriggerLevel(double *level);
#endif 

    
    ///////////////////////////////////////////////////////////
    // Device Alignment
    ///////////////////////////////////////////////////////////
    
#ifdef IS_RSA_API  // V2-only content 
    RSA_API_DLL ReturnStatus ALIGN_GetWarmupStatus(bool* warmedUp);
    RSA_API_DLL ReturnStatus ALIGN_GetAlignmentNeeded(bool* needed);
    RSA_API_DLL ReturnStatus ALIGN_RunAlignment();
#else // IS_RSA300_API -- Legacy support
    RSA300_API_DLL ReturnStatus IsAlignmentNeeded(bool *needed);
    RSA300_API_DLL ReturnStatus RunAlignment();
    RSA300_API_DLL double GetDeviceTemperature();
#endif 

    
    ///////////////////////////////////////////////////////////
    // Device Operation (global)
    ///////////////////////////////////////////////////////////
    
#ifdef IS_RSA_API  // V2-only content 
    RSA_API_DLL ReturnStatus DEVICE_GetEnable(bool* enable);
    RSA_API_DLL ReturnStatus DEVICE_Run();
    RSA_API_DLL ReturnStatus DEVICE_Stop();
    RSA_API_DLL ReturnStatus DEVICE_PrepareForRun();
    RSA_API_DLL ReturnStatus DEVICE_StartFrameTransfer();

    enum { DEVEVENT_OVERRANGE = 0, DEVEVENT_TRIGGER = 1, DEVEVENT_1PPS = 2 };
    RSA_API_DLL ReturnStatus DEVICE_GetEventStatus(int eventID, bool* eventOccurred, uint64_t* eventTimestamp);

#else // IS_RSA300_API -- Legacy support
    typedef enum
    {
        stopped = 0,
        running = 1
    } RunMode;
    RSA300_API_DLL ReturnStatus GetRunState(RunMode* runMode);
    RSA300_API_DLL ReturnStatus Run();
    RSA300_API_DLL ReturnStatus Stop();
    RSA300_API_DLL ReturnStatus PrepareForRun();
    RSA300_API_DLL ReturnStatus StartFrameTransfer();
#endif 
    
    ///////////////////////////////////////////////////////////
    // System/Reference Time 
    ///////////////////////////////////////////////////////////

    RSA_API_DLL  ReturnStatus REFTIME_GetTimestampRate(uint64_t* o_refTimestampRate);
    RSA_API_DLL  ReturnStatus REFTIME_GetCurrentTime(time_t* o_timeSec, uint64_t* o_timeNsec, uint64_t* o_timestamp);
    RSA_API_DLL  ReturnStatus REFTIME_GetTimeFromTimestamp(uint64_t i_timestamp, time_t* o_timeSec, uint64_t* o_timeNsec);
    RSA_API_DLL  ReturnStatus REFTIME_GetTimestampFromTime(time_t i_timeSec, uint64_t i_timeNsec, uint64_t* o_timestamp);
    RSA_API_DLL  ReturnStatus REFTIME_GetIntervalSinceRefTimeSet(double* sec);
#ifdef IS_RSA_API  // V2-only content 
    RSA_API_DLL  ReturnStatus REFTIME_SetReferenceTime(time_t refTimeSec, uint64_t refTimeNsec, uint64_t refTimestamp);
    RSA_API_DLL  ReturnStatus REFTIME_GetReferenceTime(time_t* refTimeSec, uint64_t* refTimeNsec, uint64_t* refTimestamp);
#endif

    ///////////////////////////////////////////////////////////
    // IQ Block Data aquisition
    ///////////////////////////////////////////////////////////

#ifdef IS_RSA_API  // V2-only content
    RSA_API_DLL ReturnStatus IQBLK_GetMaxIQBandwidth(double* maxBandwidth);
    RSA_API_DLL ReturnStatus IQBLK_GetMinIQBandwidth(double* minBandwidth);
    RSA_API_DLL ReturnStatus IQBLK_GetMaxIQRecordLength(int* maxSamples);
    
    RSA_API_DLL ReturnStatus IQBLK_SetIQBandwidth(double iqBandwidth);
    RSA_API_DLL ReturnStatus IQBLK_GetIQBandwidth(double* iqBandwidth);
    RSA_API_DLL ReturnStatus IQBLK_GetIQSampleRate(double* iqSampleRate);
    RSA_API_DLL ReturnStatus IQBLK_SetIQRecordLength(int recordLength);
    RSA_API_DLL ReturnStatus IQBLK_GetIQRecordLength(int* recordLength);

    RSA_API_DLL ReturnStatus IQBLK_AcquireIQData();
    RSA_API_DLL ReturnStatus IQBLK_WaitForIQDataReady(int timeoutMsec, bool* ready);

    RSA_API_DLL ReturnStatus IQBLK_GetIQData(float* iqData, int* outLength, int reqLength);
    RSA_API_DLL ReturnStatus IQBLK_GetIQDataDeinterleaved(float* iData, float* qData, int* outLength, int reqLength);
    RSA_API_DLL ReturnStatus IQBLK_GetIQDataCplx(Cplx32* iqData, int* outLength, int reqLength);
    
    // Bit field definitions for "acqStatus" word of IQBLK_ACQINFO struct
    enum {
        IQBLK_STATUS_INPUT_OVERRANGE = (1 << 0),
        IQBLK_STATUS_FREQREF_UNLOCKED = (1 << 1),  // frequency reference unlocked
        IQBLK_STATUS_ACQ_SYS_ERROR = (1 << 2),      // acquisition system error within block 
        IQBLK_STATUS_DATA_XFER_ERROR = (1 << 3),   // data transfer error within block
    };
    typedef struct
    {
        uint64_t  sample0Timestamp;         // timestamp of first sample in block 
        uint64_t  triggerSampleIndex;       // sample index of trigger event in block
        uint64_t  triggerTimestamp;         // timestamp of trigger event in block
        uint32_t  acqStatus;                // 0:no errors, >0:acq events/issues; see IQBLK_STATUS_* bit enums to decode...
    } IQBLK_ACQINFO;
    RSA_API_DLL ReturnStatus IQBLK_GetIQAcqInfo(IQBLK_ACQINFO* acqInfo);   // Query IQ block acquisition info

#else // IS_RSA300_API -- Legacy support
    RSA300_API_DLL ReturnStatus GetMaxIQBandwidth(double* maxBandwidth);
    RSA300_API_DLL ReturnStatus GetMinIQBandwidth(double* minBandwidth);
    RSA300_API_DLL ReturnStatus GetMaxAcquisitionSamples(unsigned long* maxSamples);

    RSA300_API_DLL ReturnStatus SetIQBandwidth(double iqBandwidth);
    RSA300_API_DLL ReturnStatus GetIQBandwidth(double* iqBandwidth);
    RSA300_API_DLL ReturnStatus GetIQSampleRate(double* iqSampleRate);
    RSA300_API_DLL ReturnStatus SetIQRecordLength(long recordLength);
    RSA300_API_DLL ReturnStatus GetIQRecordLength(long* recordLength);

    RSA300_API_DLL ReturnStatus WaitForIQDataReady(int timeoutMsec, bool* ready);
    RSA300_API_DLL ReturnStatus GetIQData(float* iqData, int startIndex, int length);
    RSA300_API_DLL ReturnStatus GetIQDataDeinterleaved(float* iData, float* qData, int startIndex, int length);
    RSA300_API_DLL ReturnStatus GetIQDataCplx(Cplx32* iqData, int startIndex, int length);

    // Query IQ block acquisition status
    typedef struct
    {
        uint16_t acqDataStatus;             // See AcqDataStatus enumeration for bit definitions
        uint64_t acquisitionTimestamp;
        uint32_t frameID;
        uint16_t trigger1Index;
        uint16_t trigger2Index;
        uint16_t timeSyncIndex;
    } IQHeader;

    RSA300_API_DLL ReturnStatus GetIQHeader(IQHeader* header);
#endif 

    
    ///////////////////////////////////////////////////////////
    // Spectrum Trace acquisition
    ///////////////////////////////////////////////////////////

    //  Spectrum windowing functions
    typedef enum
    {
        SpectrumWindow_Kaiser = 0,
        SpectrumWindow_Mil6dB = 1,
        SpectrumWindow_BlackmanHarris = 2,
        SpectrumWindow_Rectangle = 3,
        SpectrumWindow_FlatTop = 4,
        SpectrumWindow_Hann = 5
    } SpectrumWindows;

    //  Spectrum traces
    typedef enum
    {
        SpectrumTrace1 = 0,
        SpectrumTrace2 = 1,
        SpectrumTrace3 = 2
    } SpectrumTraces;

    //  Spectrum trace detector
    typedef enum
    {
        SpectrumDetector_PosPeak = 0,
        SpectrumDetector_NegPeak = 1,
        SpectrumDetector_AverageVRMS = 2,
        SpectrumDetector_Sample = 3
    } SpectrumDetectors;

    //  Spectrum trace output vertical unit
    typedef enum
    {
        SpectrumVerticalUnit_dBm = 0,
        SpectrumVerticalUnit_Watt = 1,
        SpectrumVerticalUnit_Volt = 2,
        SpectrumVerticalUnit_Amp = 3,
        SpectrumVerticalUnit_dBmV = 4
    } SpectrumVerticalUnits;

    //  Spectrum settings structure
    //  The actual values are returned from SPECTRUM_GetSettings() function
    //  Use SPECTRUM_GetLimits() to get the limits of the settings
    typedef struct
    {
        double span;
        double rbw;
        bool enableVBW;
        double vbw;
        int traceLength;                    //  MUST be odd number
        SpectrumWindows window;
        SpectrumVerticalUnits verticalUnit;

        //  additional settings return from SPECTRUM_GetSettings()
        double actualStartFreq;
        double actualStopFreq;
        double actualFreqStepSize;
        double actualRBW;
        double actualVBW;
        int actualNumIQSamples;
    } Spectrum_Settings;

    //  Spectrum limits
    typedef struct
    {
        double maxSpan;
        double minSpan;
        double maxRBW;
        double minRBW;
        double maxVBW;
        double minVBW;
        int maxTraceLength;
        int minTraceLength;
    } Spectrum_Limits;

    //  Spectrum result trace information
    typedef struct
    {
        uint64_t timestamp;         //  timestamp of the first acquisition sample
        uint16_t acqDataStatus;     // See AcqDataStatus enumeration for bit definitions
    } Spectrum_TraceInfo;

    //  Enable/disable Spectrum measurement
    RSA_API_DLL ReturnStatus SPECTRUM_SetEnable(bool enable);
    RSA_API_DLL ReturnStatus SPECTRUM_GetEnable(bool *enable);

    //  Set spectrum settings to default values
    RSA_API_DLL ReturnStatus SPECTRUM_SetDefault();

    //  Set/get spectrum settings
    RSA_API_DLL ReturnStatus SPECTRUM_SetSettings(Spectrum_Settings settings);
    RSA_API_DLL ReturnStatus SPECTRUM_GetSettings(Spectrum_Settings *settings);

    //  Set/get spectrum trace settings
    RSA_API_DLL ReturnStatus SPECTRUM_SetTraceType(SpectrumTraces trace, bool enable, SpectrumDetectors detector);
    RSA_API_DLL ReturnStatus SPECTRUM_GetTraceType(SpectrumTraces trace, bool *enable, SpectrumDetectors *detector);

    //  Get spectrum setting limits
    RSA_API_DLL ReturnStatus SPECTRUM_GetLimits(Spectrum_Limits *limits);

#ifdef IS_RSA_API  // V2-only content 
    //  Start Trace acquisition
    RSA_API_DLL ReturnStatus SPECTRUM_AcquireTrace();
    //  Wait for spectrum trace ready
    RSA_API_DLL ReturnStatus SPECTRUM_WaitForTraceReady(int timeoutMsec, bool *ready);
#else // IS_RSA300_API -- Legacy support
    //  Wait for spectrum trace ready
    RSA300_API_DLL ReturnStatus SPECTRUM_WaitForDataReady(int timeoutMsec, bool *ready);
#endif

    //  Get spectrum trace data
    RSA_API_DLL ReturnStatus SPECTRUM_GetTrace(SpectrumTraces trace, int maxTracePoints, float *traceData, int *outTracePoints);

    //  Get spectrum trace result information
    RSA_API_DLL ReturnStatus SPECTRUM_GetTraceInfo(Spectrum_TraceInfo *traceInfo);

    
    ///////////////////////////////////////////////////////////
    // DPX Bitmap, Traces and Spectrogram
    ///////////////////////////////////////////////////////////
    
    typedef struct
    {
        int32_t fftPerFrame;
        int64_t fftCount;
        int64_t frameCount;
        double timestamp;
        uint32_t acqDataStatus;     // See AcqDataStatus enumeration for bit definitions

        double minSigDuration;
        bool minSigDurOutOfRange;

        int32_t spectrumBitmapWidth;
        int32_t spectrumBitmapHeight;
        int32_t spectrumBitmapSize;
        int32_t spectrumTraceLength;
        int32_t numSpectrumTraces;

        bool spectrumEnabled;
        bool spectrogramEnabled;

        float* spectrumBitmap;
        float** spectrumTraces;

        int32_t sogramBitmapWidth;
        int32_t sogramBitmapHeight;
        int32_t sogramBitmapSize;
        int32_t sogramBitmapNumValidLines;
        uint8_t* sogramBitmap;
        double* sogramBitmapTimestampArray;
        int16_t* sogramBitmapContainTriggerArray;

    } DPX_FrameBuffer;

    typedef struct
    {
        int32_t bitmapWidth;
        int32_t bitmapHeight;
        double sogramTraceLineTime;
        double sogramBitmapLineTime;
    } DPX_SogramSettingsStruct;

    typedef struct
    {
        bool enableSpectrum;
        bool enableSpectrogram;
        int32_t bitmapWidth;
        int32_t bitmapHeight;
        int32_t traceLength;
        float decayFactor;
        double actualRBW;
    } DPX_SettingsStruct;

    typedef enum
    {
        TraceTypeAverage = 0,
        TraceTypeMax = 1,
        TraceTypeMaxHold = 2,
        TraceTypeMin = 3,
        TraceTypeMinHold = 4
    } TraceType;

    typedef enum
    {
        VerticalUnit_dBm = 0,
        VerticalUnit_Watt = 1,
        VerticalUnit_Volt = 2,
        VerticalUnit_Amp = 3
    } VerticalUnitType;

#ifdef IS_RSA_API  // V2-only content 
    RSA_API_DLL ReturnStatus DPX_GetEnable(bool* enable);
    RSA_API_DLL ReturnStatus DPX_SetEnable(bool enable);
#else // IS_RSA300_API -- Legacy support
    RSA300_API_DLL ReturnStatus GetDPXEnabled(bool* enabled);
    RSA300_API_DLL ReturnStatus SetDPXEnabled(bool enabled);
#endif

    RSA_API_DLL ReturnStatus DPX_SetParameters(double fspan, double rbw, int32_t bitmapWidth, int32_t tracePtsPerPixel, 
                                               VerticalUnitType yUnit, double yTop, double yBottom, 
                                               bool infinitePersistence, double persistenceTimeSec, bool showOnlyTrigFrame);
    RSA_API_DLL ReturnStatus DPX_Configure(bool enableSpectrum, bool enableSpectrogram);
    RSA_API_DLL ReturnStatus DPX_GetSettings(DPX_SettingsStruct *pSettings);

    enum { DPX_TRACEIDX_1 = 0, DPX_TRACEIDX_2 = 1, DPX_TRACEIDX_3 = 2 };   // traceIndex enumerations
    RSA_API_DLL ReturnStatus DPX_SetSpectrumTraceType(int32_t traceIndex, TraceType type);

#ifdef IS_RSA_API  // V2-only content 
    RSA_API_DLL ReturnStatus DPX_GetRBWRange(double fspan, double* minRBW, double* maxRBW);
    RSA_API_DLL ReturnStatus DPX_Reset();
    RSA_API_DLL ReturnStatus DPX_WaitForDataReady(int timeoutMsec, bool* ready);
#else // IS_RSA300_API -- Legacy support
    RSA300_API_DLL ReturnStatus DPX_FindRBWRange(double fspan, double* minRBW, double* maxRBW);
    RSA300_API_DLL ReturnStatus DPX_ResetDPx();
    RSA300_API_DLL ReturnStatus WaitForDPXDataReady(int timeoutMsec, bool* ready);
#endif

    RSA_API_DLL ReturnStatus DPX_GetFrameInfo(int64_t* frameCount, int64_t* fftCount);

    //  Spectrogram 
    RSA_API_DLL ReturnStatus DPX_SetSogramParameters(double timePerBitmapLine, double timeResolution, double maxPower, double minPower);
    RSA_API_DLL ReturnStatus DPX_SetSogramTraceType(TraceType traceType);
    RSA_API_DLL ReturnStatus DPX_GetSogramSettings(DPX_SogramSettingsStruct *pSettings);

    RSA_API_DLL ReturnStatus DPX_GetSogramHiResLineCountLatest(int32_t* lineCount);
    RSA_API_DLL ReturnStatus DPX_GetSogramHiResLineTriggered(bool* triggered, int32_t lineIndex);
    RSA_API_DLL ReturnStatus DPX_GetSogramHiResLineTimestamp(double* timestamp, int32_t lineIndex);
    RSA_API_DLL ReturnStatus DPX_GetSogramHiResLine(int16_t* vData, int32_t* vDataSize, int32_t lineIndex, double* dataSF, int32_t tracePoints, int32_t firstValidPoint);

    //  Frame Buffer
    RSA_API_DLL ReturnStatus DPX_GetFrameBuffer(DPX_FrameBuffer* frameBuffer);

    //  The client is required to call FinishFrameBuffer() before the next frame can be available.
    RSA_API_DLL ReturnStatus DPX_FinishFrameBuffer();
    RSA_API_DLL ReturnStatus DPX_IsFrameBufferAvailable(bool* frameAvailable);

    
    ///////////////////////////////////////////////////////////
    // Audio Demod
    ///////////////////////////////////////////////////////////
    
    // Get/Set the demod mode to one of:
    typedef enum
    {
        ADM_FM_8KHZ = 0,
        ADM_FM_13KHZ = 1,
        ADM_FM_75KHZ = 2,
        ADM_FM_200KHZ = 3,
        ADM_AM_8KHZ = 4,
        ADM_NONE    // internal use only
    } AudioDemodMode;
    RSA_API_DLL ReturnStatus AUDIO_SetMode(AudioDemodMode mode);
    RSA_API_DLL ReturnStatus AUDIO_GetMode(AudioDemodMode *mode);

    // Get/Set the volume 0.0 -> 1.0. 
    RSA_API_DLL ReturnStatus AUDIO_SetVolume(float volume);
    RSA_API_DLL ReturnStatus AUDIO_GetVolume(float *_volume);

    // Mute/unmute the speaker output.  This does not stop the processing or data callbacks.
    RSA_API_DLL ReturnStatus AUDIO_SetMute(bool mute);
    RSA_API_DLL ReturnStatus AUDIO_GetMute(bool* _mute);

#ifdef IS_RSA_API  // V2-only content 
    // Tune Offset from center frequency (default is 0 Hz offset)
    RSA_API_DLL ReturnStatus AUDIO_SetFrequencyOffset(double freqOffsetHz);
    RSA_API_DLL ReturnStatus AUDIO_GetFrequencyOffset(double* freqOffsetHz);
#endif

#ifdef IS_RSA_API  // V2-only content 
    RSA_API_DLL ReturnStatus AUDIO_Start();                     // Start the audio demod output generation
    RSA_API_DLL ReturnStatus AUDIO_Stop();                      // Stop the audio demod output generation
    RSA_API_DLL ReturnStatus AUDIO_GetEnable(bool *enable);     // Query the audio demod state
#else // IS_RSA300_API -- Legacy support
    RSA300_API_DLL ReturnStatus AUDIO_StartAudio();
    RSA300_API_DLL ReturnStatus AUDIO_StopAudio();
    RSA300_API_DLL ReturnStatus AUDIO_Running(bool *_running);
#endif

    // Get data from audio ooutput
    // User must allocate data to inSize before calling
    // Actual data returned is in outSize and will not exceed inSize
    RSA_API_DLL ReturnStatus AUDIO_GetData(int16_t* data, uint16_t inSize, uint16_t *outSize);

    
    ///////////////////////////////////////////////////////////
    // IF(ADC) Data Streaming to disk
    ///////////////////////////////////////////////////////////
    
    typedef enum
    {
        StreamingModeRaw = 0,
        StreamingModeFramed = 1
    } StreamingMode;
#ifdef IS_RSA_API  // V2-only content 
    RSA_API_DLL ReturnStatus IFSTREAM_SetEnable(bool enable);
    RSA_API_DLL ReturnStatus IFSTREAM_GetActiveStatus(bool *active);
    RSA_API_DLL ReturnStatus IFSTREAM_SetDiskFileMode(StreamingMode mode);
    RSA_API_DLL ReturnStatus IFSTREAM_SetDiskFilePath(const char *path);
    RSA_API_DLL ReturnStatus IFSTREAM_SetDiskFilenameBase(const char *base);
    enum { IFSSDFN_SUFFIX_INCRINDEX_MIN = 0, IFSSDFN_SUFFIX_TIMESTAMP = -1, IFSSDFN_SUFFIX_NONE = -2 };  // enums for the special fileSuffixCtl values
    RSA_API_DLL ReturnStatus IFSTREAM_SetDiskFilenameSuffix(int suffixCtl);
    RSA_API_DLL ReturnStatus IFSTREAM_SetDiskFileLength(int msec);
    RSA_API_DLL ReturnStatus IFSTREAM_SetDiskFileCount(int count);
#else // IS_RSA300_API -- Legacy support
    RSA300_API_DLL ReturnStatus SetStreamADCToDiskEnabled(bool enabled);
    RSA300_API_DLL ReturnStatus GetStreamADCToDiskActive(bool *enabled);
    RSA300_API_DLL ReturnStatus SetStreamADCToDiskMode(StreamingMode mode);
    RSA300_API_DLL ReturnStatus SetStreamADCToDiskPath(const char *path);
    RSA300_API_DLL ReturnStatus SetStreamADCToDiskFilenameBase(const char *filename);
    RSA300_API_DLL ReturnStatus SetStreamADCToDiskMaxTime(long milliseconds);
    RSA300_API_DLL ReturnStatus SetStreamADCToDiskMaxFileCount(int maximum);
#endif

    ///////////////////////////////////////////////////////////
    // IQ Data Streaming to client or disk
    ///////////////////////////////////////////////////////////

    // NOTE:  IQSTREAM output should be operated as the ONLY active API processing type.
    //        Do not run other API processing (DPX, IQ Block acq, Audio, IF streaming, Spectrum) 
    //        at the same time as IQ Streaming, as it can and will cause incorrect behavior
    //        of all active processing.

#ifdef IS_RSA_API  // V2-only content 
    RSA_API_DLL ReturnStatus IQSTREAM_GetMaxAcqBandwidth(double* maxBandwidthHz);
    RSA_API_DLL ReturnStatus IQSTREAM_GetMinAcqBandwidth(double* minBandwidthHz);
#endif
    RSA_API_DLL ReturnStatus IQSTREAM_SetAcqBandwidth(double bwHz_req);
    RSA_API_DLL ReturnStatus IQSTREAM_GetAcqParameters(double* bwHz_act, double* srSps);

    typedef enum { IQSOD_CLIENT = 0, IQSOD_FILE_TIQ = 1, IQSOD_FILE_SIQ = 2, IQSOD_FILE_SIQ_SPLIT = 3 } IQSOUTDEST;
    typedef enum { IQSODT_SINGLE = 0, IQSODT_INT32 = 1, IQSODT_INT16 = 2 } IQSOUTDTYPE;
    RSA_API_DLL ReturnStatus IQSTREAM_SetOutputConfiguration(IQSOUTDEST dest, IQSOUTDTYPE dtype);

    RSA_API_DLL ReturnStatus IQSTREAM_SetIQDataBufferSize(int reqSize);
    RSA_API_DLL ReturnStatus IQSTREAM_GetIQDataBufferSize(int* maxSize);

    RSA_API_DLL ReturnStatus IQSTREAM_SetDiskFilenameBaseW(const wchar_t* filenameBaseW);
    RSA_API_DLL ReturnStatus IQSTREAM_SetDiskFilenameBase(const char* filenameBase);
    enum { IQSSDFN_SUFFIX_INCRINDEX_MIN = 0, IQSSDFN_SUFFIX_TIMESTAMP = -1, IQSSDFN_SUFFIX_NONE = -2 };  // enums for the special fileSuffixCtl values
    RSA_API_DLL ReturnStatus IQSTREAM_SetDiskFilenameSuffix(int suffixCtl);
    RSA_API_DLL ReturnStatus IQSTREAM_SetDiskFileLength(int msec);

    RSA_API_DLL ReturnStatus IQSTREAM_Start();
    RSA_API_DLL ReturnStatus IQSTREAM_Stop();
#ifdef IS_RSA_API  // V2-only content 
    RSA_API_DLL ReturnStatus IQSTREAM_GetEnable(bool* enable);
#else // IS_RSA300_API -- Legacy support
    RSA300_API_DLL ReturnStatus IQSTREAM_GetEnabled(bool* enabled);
#endif

    enum {
        IQSTRM_STATUS_OVERRANGE = (1 << 0),         // RF input overrange detected (non-sticky(client): in this block; sticky(client+file): in entire run)
        IQSTRM_STATUS_XFER_DISCONTINUITY = (1 << 1),// Continuity error (gap) detected in IF frame transfers 
        IQSTRM_STATUS_IBUFF75PCT = (1 << 2),        // Input buffer >= 75 % full, indicates IQ processing may have difficulty keeping up with IF sample stream
        IQSTRM_STATUS_IBUFFOVFLOW = (1 << 3),       // Input buffer overflow, IQ processing cannot keep up with IF sample stream, input samples dropped
        IQSTRM_STATUS_OBUFF75PCT = (1 << 4),        // Output buffer >= 75% full, indicates output sink (disk or client) may have difficulty keeping up with IQ output stream
        IQSTRM_STATUS_OBUFFOVFLOW = (1 << 5),       // Output buffer overflow, IQ unloading not keeping up with IA sample stream, output samples dropped
        IQSTRM_STATUS_NONSTICKY_SHIFT = 0,          // Non-sticky status bits are shifted this many bits left from LSB
        IQSTRM_STATUS_STICKY_SHIFT = 16             // Sticky status bits are shifted this many bits left from LSB
    };

    enum { IQSTRM_MAXTRIGGERS = 100 };  // max size of IQSTRMIQINFO triggerIndices array 
    typedef struct
    {
        uint64_t  timestamp;            // timestamp of first IQ sample returned in block
        int       triggerCount;         // number of triggers detected in this block
        int*      triggerIndices;       // array of trigger sample indices in block (overwritten on each new block query)
        double    scaleFactor;          // sample scale factor for Int16, Int32 data types (scales to volts into 50-ohms)
        uint32_t  acqStatus;            // 0:acq OK, >0:acq issues; see IQSTRM_STATUS enums to decode...
    } IQSTRMIQINFO;

    RSA_API_DLL ReturnStatus IQSTREAM_GetIQData(void* iqdata, int* iqlen, IQSTRMIQINFO* iqinfo);

    RSA_API_DLL ReturnStatus IQSTREAM_GetDiskFileWriteStatus(bool* isComplete, bool *isWriting);

    enum { IQSTRM_FILENAME_DATA_IDX = 0, IQSTRM_FILENAME_HEADER_IDX = 1 };
    typedef struct
    {
        uint64_t  numberSamples;              // number of samples written to file
        uint64_t  sample0Timestamp;           // timestamp of first sample in file 
        uint64_t  triggerSampleIndex;         // if triggering enabled, sample index of 1st trigger event in file
        uint64_t  triggerTimestamp;           // if triggering enabled, timestamp of trigger event
        uint32_t  acqStatus;                  // 0=acq OK, >0 acq issues; see IQSTRM_STATUS enums to decode...
        wchar_t** filenames;                  // [0]:data filename, [1]:header filename
    } IQSTRMFILEINFO;
#ifdef IS_RSA_API  // V2-only content 
    RSA_API_DLL ReturnStatus IQSTREAM_GetDiskFileInfo(IQSTRMFILEINFO* fileinfo);
#else // IS_RSA300_API -- Legacy support
    RSA300_API_DLL ReturnStatus IQSTREAM_GetFileInfo(IQSTRMFILEINFO* fileinfo);
#endif

    RSA_API_DLL void IQSTREAM_ClearAcqStatus();


    ///////////////////////////////////////////////////////////
    // Stored IF Data File Playback
    ///////////////////////////////////////////////////////////

    RSA_API_DLL ReturnStatus PLAYBACK_OpenDiskFile(
        const wchar_t * fileName,
        int startPercentage,
        int stopPercentage,
        double skipTimeBetweenFullAcquisitions,
        bool loopAtEndOfFile,
        bool emulateRealTime);

#ifdef IS_RSA_API  // V2-only content 
    RSA_API_DLL ReturnStatus PLAYBACK_GetReplayComplete(bool* complete);
#else // IS_RSA300_API -- Legacy support
    RSA300_API_DLL ReturnStatus PLAYBACK_HasReplayCompleted(bool * isCompleted);
#endif


#ifdef IS_RSA_API  // V2-only content 
    ///////////////////////////////////////////////////////////
    // Tracking Generator control
    ///////////////////////////////////////////////////////////

    RSA_API_DLL ReturnStatus TRKGEN_GetHwInstalled(bool *installed);
    RSA_API_DLL ReturnStatus TRKGEN_SetEnable(bool enable);
    RSA_API_DLL ReturnStatus TRKGEN_GetEnable(bool *enable);
    RSA_API_DLL ReturnStatus TRKGEN_SetOutputLevel(double leveldBm);
    RSA_API_DLL ReturnStatus TRKGEN_GetOutputLevel(double *leveldBm);
#endif

#ifdef IS_RSA_API  // V2-only content 
    ///////////////////////////////////////////////////////////
    // GNSS Rx Control and Output
    ///////////////////////////////////////////////////////////

    typedef enum { GNSS_NOSYS = 0, GNSS_GPS_GLONASS = 1, GNSS_GPS_BEIDOU = 2, GNSS_GPS = 3, GNSS_GLONASS = 4, GNSS_BEIDOU = 5, } GNSS_SATSYS;

    RSA_API_DLL ReturnStatus GNSS_GetHwInstalled(bool *installed);
    RSA_API_DLL ReturnStatus GNSS_SetEnable(bool enable);
    RSA_API_DLL ReturnStatus GNSS_GetEnable(bool* enable);
    RSA_API_DLL ReturnStatus GNSS_SetSatSystem(GNSS_SATSYS satSystem);
    RSA_API_DLL ReturnStatus GNSS_GetSatSystem(GNSS_SATSYS *satSystem);
    RSA_API_DLL ReturnStatus GNSS_SetAntennaPower(bool powered);
    RSA_API_DLL ReturnStatus GNSS_GetAntennaPower(bool* powered);
    RSA_API_DLL ReturnStatus GNSS_GetNavMessageData(int* msgLen, const char** message);
    RSA_API_DLL ReturnStatus GNSS_ClearNavMessageData();
    RSA_API_DLL ReturnStatus GNSS_Get1PPSTimestamp(bool* isValid, uint64_t* timestamp1PPS);
#endif

#ifdef IS_RSA_API  // V2-only content 
    ///////////////////////////////////////////////////////////
    // Power and Battery Status
    ///////////////////////////////////////////////////////////

    typedef struct
    {
        bool externalPowerPresent;
        bool batteryPresent;
        double batteryChargeLevel;      //  in percent
        bool batteryCharging;
        bool batteryOverTemperature;
        bool batteryHardwareError;
    } POWER_INFO;

    RSA_API_DLL ReturnStatus POWER_GetStatus(POWER_INFO* powerInfo);
#endif

#ifdef __cplusplus
}  //extern "C"
}  //namespace __NAMESPACE_API__
#endif //__cplusplus

#endif // RSA_API_H
"""