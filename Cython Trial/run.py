# run.py
import RSA_API
import numpy as np

deviceID = 0
apiVersion = 'yar'.encode()

# RSA_API.DEVICE_Connect(deviceID)
RSA_API.DEVICE_GetAPIVersion(apiVersion)

print(apiVersion)
