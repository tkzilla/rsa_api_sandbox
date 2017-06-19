from rsa_api import *
import matplotlib.pyplot as plt

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

devInfo = DEVICE_GetInfo_py()
print('Device Info: {}'.format(devInfo))


TRIG_SetTriggerMode_py(TriggerMode.freeRun)
print(TRIG_GetTriggerMode_py())
TRIG_SetIFPowerTriggerLevel_py(-20)
print('Trigger level: {}'.format(TRIG_GetIFPowerTriggerLevel_py()))

print(ALIGN_GetAlignmentNeeded_py())
print(ALIGN_GetWarmupStatus_py())
#
# DEVICE_Run_py()
# print(DEVICE_GetEnable_py())
#
# print(DEVICE_GetEventStatus_py(0))
#
#
# print(REFTIME_GetCurrentTime_py())
# print(REFTIME_GetTimeFromTimestamp_py(1208103626940))
# print(REFTIME_GetTimestampRate_py())
# print(REFTIME_GetTimestampFromTime_py(1496856313, 42697429))
# print(REFTIME_GetIntervalSinceRefTimeSet_py())

CONFIG_Preset_py()
CONFIG_SetCenterFreq_py(2.4453e9)
CONFIG_SetReferenceLevel_py(0)
print(CONFIG_GetCenterFreq_py())
print(CONFIG_GetReferenceLevel_py())

# print(IQBLK_GetMaxIQRecordLength_py())
#
# rl = 100000
# iData = np.empty(shape=(rl), dtype=np.float32, order='c')
# qData = np.empty(shape=(rl), dtype=np.float32, order='c')
#
# IQBLK_SetIQRecordLength_py(rl)
# DEVICE_Run_py()
# IQBLK_AcquireIQData_py()
# while IQBLK_WaitForIQDataReady_py(100) == False:
#     print(IQBLK_WaitForIQDataReady_py(100))
# # i, q = IQBLK_GetIQDataDeinterleaved_py(rl)
# iq = IQBLK_GetIQData_py(rl)
# i, q = IQBLK_Acquire_py(IQBLK_GetIQDataDeinterleaved_py, rl, 100)

# i = iq[0:-1:2]
# q = iq[1:-1:2]
# fig = plt.figure(1, figsize=(15, 10))
# fig.suptitle('I and Q vs Time', fontsize='20')
# ax1 = plt.subplot(211, facecolor='k')
# ax1.plot(i, color='y')
# ax1.set_ylabel('I (V)')
# # ax1.set_xlim([time[0] * 1e3, time[-1] * 1e3])
# ax2 = plt.subplot(212, facecolor='k')
# ax2.plot(q, color='c')
# ax2.set_ylabel('Q (V)')
# ax2.set_xlabel('Time (msec)')
# # ax2.set_xlim([time[0] * 1e3, time[-1] * 1e3])
# plt.tight_layout()
# plt.show()

# print(IQBLK_GetIQAcqInfo_py())
#
# SPECTRUM_SetEnable_py(True)
# print(SPECTRUM_GetEnable_py())
# SPECTRUM_SetDefault_py()
# SPECTRUM_SetSettings_py(span=40e6, rbw=10e3, traceLength=801)
# print(SPECTRUM_GetSettings_py())
#
# SPECTRUM_SetTraceType_py(0, True, 0)
# print(SPECTRUM_GetTraceType_py(0))
# print(SPECTRUM_GetLimits_py())
#
# # spectrum = SPECTRUM_Acquire_py(tracePoints=801)
# DEVICE_Run_py()
# SPECTRUM_AcquireTrace_py()
# while not SPECTRUM_WaitForTraceReady_py(100):
#     pass
# print(SPECTRUM_GetTraceInfo_py())
# print('Event Status: {}'.format(DEVICE_GetEventStatus_py(DEVEVENT_OVERRANGE)))
# spectrum = SPECTRUM_GetTrace_py(SpectrumTraces.SpectrumTrace1, 801)
#
# plt.figure(1, figsize=(15, 10))
# ax = plt.subplot(111, facecolor='k')
# ax.plot(spectrum, color='y')
# ax.set_title('Spectrum Trace')
# ax.set_xlabel('Frequency (Hz)')
# ax.set_ylabel('Amplitude (dBm)')
# plt.tight_layout()
# plt.show()

fspan = 40e6
rbw = 100e3
tracePtsPerPixel = 1
yUnit = 0#VerticalUnitType.VerticalUnit_dBm
yTop = 0
yBottom = yTop - 100
infinitePersistence = False
persistenceTimeSec = 1
showOnlyTrigFrame = False
DPX_SetEnable_py(True)
DPX_Reset_py()
DPX_SetSpectrumTraceType_py(0, 1)
DPX_SetParameters_py(fspan, rbw, tracePtsPerPixel, yUnit, yTop, yBottom,
                     infinitePersistence, persistenceTimeSec, showOnlyTrigFrame)
print(DPX_GetSettings_py())
fb = DPX_AcquireFB_py()

fig = plt.figure()
ax1 = fig.add_subplot(131)
ax1.imshow(fb.spectrumBitmap, cmap='gist_stern')
ax1.set_aspect(7)
ax2 = fig.add_subplot(132)
for t in fb.spectrumTraces:
    ax2.plot(t)
ax3 = fig.add_subplot(133)
ax3.imshow(fb.sogramBitmap, cmap='gist_stern')
ax3.set_aspect(7)
plt.tight_layout()
plt.show()
#
#
# AUDIO_SetMode_py(3)
# print(AUDIO_GetMode_py())
# AUDIO_SetVolume_py(0.5)
# print(AUDIO_GetVolume_py())
# AUDIO_SetMute_py(False)
# print(AUDIO_GetMute_py())
#
# DEVICE_Run_py()
# AUDIO_Start_py()
# print(AUDIO_GetEnable_py())
# inSize = 1000
# data = AUDIO_GetData_py(inSize)
# plt.plot(data)
# plt.show()

# IFSTREAM_SetDiskFileMode_py(StreamingMode.StreamingModeFramed)
# IFSTREAM_SetDiskFilePath_py(b'C:\\SignalVu-PC Files\\garbage\\')
# IFSTREAM_SetDiskFilenameBase_py(b'if_stream_test')
# IFSTREAM_SetDiskFilenameSuffix_py(IFSSDFN_SUFFIX_NONE)
# IFSTREAM_SetDiskFileLength_py(100)
# IFSTREAM_SetDiskFileCount_py(1)
# DEVICE_Run_py()
# IFSTREAM_SetEnable_py(True)
# while not IFSTREAM_GetActiveStatus_py():
#     pass

