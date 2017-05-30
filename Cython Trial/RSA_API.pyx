from rsa_api_h cimport *
import numpy as np


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



##########################################################
# Device Connection and Info
##########################################################
print('\nDevice Connection')
cdef int numDevicesFound = 0
cdef int deviceIDs[20]
cdef char deviceSerial[20][100]
cdef char deviceType[20][20]

rs = DEVICE_Search(&numDevicesFound, deviceIDs, deviceSerial, deviceType)
print(DEVICE_GetErrorString(rs).decode())

devs = np.asarray(deviceIDs)

print('Number of devices: {}'.format(numDevicesFound))
print('Device serial numbers: {}'.format(deviceSerial[0].decode()))
print('Device type: {}'.format(deviceType[0].decode()))

print(DEVICE_GetErrorString(DEVICE_Connect(devs[0])))
# print(DEVICE_GetErrorString(DEVICE_Reset(devs[0])))

cdef char nomenclature[100]
rs = DEVICE_GetNomenclature(nomenclature)
print(DEVICE_GetErrorString(rs).decode())
print('Nomenclature: {}'.format(nomenclature.decode()))

cdef char serialNum[100]
rs = DEVICE_GetSerialNumber(serialNum)
print(DEVICE_GetErrorString(rs).decode())
print('Serial Number: {}'.format(serialNum.decode()))

cdef char apiVersion[100]
rs = DEVICE_GetAPIVersion(apiVersion)
print(DEVICE_GetErrorString(rs).decode())
print('API Version: {}'.format(apiVersion.decode()))

cdef char fwVersion[100]
rs = DEVICE_GetFWVersion(fwVersion)
print(DEVICE_GetErrorString(rs).decode())
print('Firmware Version: {}'.format(fwVersion.decode()))

cdef char fpgaVersion[100]
rs = DEVICE_GetFPGAVersion(fpgaVersion)
print(DEVICE_GetErrorString(rs).decode())
print('FPGA Version: {}'.format(fpgaVersion.decode()))

cdef char hwVersion[100]
rs = DEVICE_GetHWVersion(hwVersion)
print(DEVICE_GetErrorString(rs).decode())
print('Hardware Version: {}'.format(hwVersion.decode()))

print('Using DEVICE_GetInfo\n')
cdef DEVICE_INFO devInfo
rs = DEVICE_GetInfo(&devInfo)
print(DEVICE_GetErrorString(rs).decode())
print('Nomenclature: {}'.format(devInfo.nomenclature.decode()))
print('Serial Number: {}'.format(devInfo.serialNum.decode()))
print('API Version: {}'.format(devInfo.apiVersion.decode()))
print('Firmware Version: {}'.format(devInfo.fwVersion.decode()))
print('FPGA Version: {}'.format(devInfo.fpgaVersion.decode()))
print('Hardware Version: {}'.format(devInfo.hwVersion.decode()))

cdef bint tempStatus
rs = DEVICE_GetOverTemperatureStatus(&tempStatus)
print(DEVICE_GetErrorString(rs).decode())
print('Temperature Status: {}'.format(tempStatus))


##########################################################
# Device Configuration (global)
##########################################################
print('\nDevice Configuration')
CONFIG_Preset()
cdef double refLevel = -20
rs = CONFIG_SetReferenceLevel(refLevel)
print(DEVICE_GetErrorString(rs).decode())
rs = CONFIG_GetReferenceLevel(&refLevel)
print('Reference Level: {}'.format(refLevel))

cdef double maxCF
cdef double minCF
rs = CONFIG_GetMaxCenterFreq(&maxCF)
print(DEVICE_GetErrorString(rs).decode())
rs = CONFIG_GetMinCenterFreq(&minCF)
print(DEVICE_GetErrorString(rs).decode())
print('Max CF: {}\nMin CF: {}'.format(maxCF, minCF))

cdef double cf = 2.4453e9
rs = CONFIG_SetCenterFreq(cf)
print(DEVICE_GetErrorString(rs).decode())
rs = CONFIG_GetCenterFreq(&cf)
print(DEVICE_GetErrorString(rs).decode())
print('Center Frequency: {}'.format(cf))

cdef bint exRefEn = 0
rs = CONFIG_SetExternalRefEnable(exRefEn)
print(DEVICE_GetErrorString(rs).decode())
rs = CONFIG_GetExternalRefEnable(&exRefEn)
print(DEVICE_GetErrorString(rs).decode())
print('External Reference Status: {}'.format(exRefEn))

cdef double extFreq
rs = CONFIG_GetExternalRefFrequency(&extFreq)
print(DEVICE_GetErrorString(rs).decode())
print('External Frequency: {}'.format(extFreq))

cdef bint autoAttenEnable = 0
rs = CONFIG_SetAutoAttenuationEnable(autoAttenEnable)
print(DEVICE_GetErrorString(rs).decode())
rs = CONFIG_GetAutoAttenuationEnable(&autoAttenEnable)
print(DEVICE_GetErrorString(rs).decode())
print('Auto Attenuation Status: {}'.format(autoAttenEnable))

cdef bint preampEnable = 1
rs = CONFIG_SetRFPreampEnable(preampEnable)
print(DEVICE_GetErrorString(rs).decode())
rs = CONFIG_GetRFPreampEnable(&preampEnable)
print(DEVICE_GetErrorString(rs).decode())
print('Preamp Status: {}'.format(preampEnable))

cdef double value = 0
rs = CONFIG_SetRFAttenuator(value)
print(DEVICE_GetErrorString(rs).decode())
rs = CONFIG_GetRFAttenuator(&value)
print(DEVICE_GetErrorString(rs).decode())
print('Attenuator Value: {}'.format(value))


##########################################################
#  Trigger Configuration
##########################################################
print('\nTrigger')
cdef TriggerMode mode = TriggerMode.triggered
rs = TRIG_SetTriggerMode(mode)
print(DEVICE_GetErrorString(rs).decode())
rs = TRIG_GetTriggerMode(&mode)
print(DEVICE_GetErrorString(rs).decode())
print('Trigger Mode: {}'.format(mode))

cdef TriggerSource source = TriggerSource.TriggerSourceIFPowerLevel
rs = TRIG_SetTriggerSource(source)
print(DEVICE_GetErrorString(rs).decode())
rs = TRIG_GetTriggerSource(&source)
print(DEVICE_GetErrorString(rs).decode())
print('Trigger Source: {}'.format(source))

cdef TriggerTransition transition = TriggerTransition.TriggerTransitionHL
rs = TRIG_SetTriggerTransition(transition)
print(DEVICE_GetErrorString(rs).decode())
rs = TRIG_GetTriggerTransition(&transition)
print(DEVICE_GetErrorString(rs).decode())
print('Trigger Transition: {}'.format(transition))

cdef double level = -30
rs = TRIG_SetIFPowerTriggerLevel(level)
print(DEVICE_GetErrorString(rs).decode())
rs = TRIG_GetIFPowerTriggerLevel(&level)
print(DEVICE_GetErrorString(rs).decode())
print('Trigger Level: {}'.format(level))

cdef double trigPosPercent = 15
rs = TRIG_SetTriggerPositionPercent(trigPosPercent)
print(DEVICE_GetErrorString(rs).decode())
rs = TRIG_GetTriggerPositionPercent(&trigPosPercent)
print(DEVICE_GetErrorString(rs).decode())
print('Trigger Position(%): {}'.format(trigPosPercent))

rs = TRIG_ForceTrigger()
print(DEVICE_GetErrorString(rs).decode())

# DEVICE_Run()
# DEVICE_Stop()
DEVICE_Disconnect()
