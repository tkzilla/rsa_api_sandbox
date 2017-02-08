# RSA_API.pyx
import RSA_API

def DEVICE_Connect(int deviceID):
    RSA_API.DEVICE_Connect(deviceID)

def DEVICE_GetAPIVersion(char* apiVersion):
    RSA_API.DEVICE_GetAPIVersion(apiVersion)
