#filereadingoptimizer
"""
Iteration 1.
Open file and get file size from the os.

"""
import os, time
from struct import *
import numpy as np

def get_header_data(filename, display):
	datafile = open(filename, 'rb', 64*1024*1024)
	data = datafile.read(16384)

	# Get and print File ID and Version Info sections of the header
	fileid = data[:27]
	#endian = unpack('1I',data[512:516])
	endian = np.fromstring(data[512:516], dtype = np.uint32)
	fileformatversion = unpack('4B', data[516:520])
	apiversion = unpack('4B', data[520:524])
	fx3version = unpack('4B', data[524:528])
	fpgaversion = unpack('4B', data[528:532])
	devicesn = data[532:596]
	versioninfo = {'fileid': fileid, 'endian': endian, 'fileformatversion': fileformatversion,
		'apiversion': apiversion, 'fx3version': fx3version, 'fpgaversion': fpgaversion, 'devicesn': devicesn}

	# Get and print the Instrument State section of the header
	referencelevel = unpack('1d', data[1024:1032])
	centerfrequency = unpack('1d', data[1032:1040])
	temperature = unpack('1d', data[1040:1048])
	alignment = unpack('1I', data[1048:1052])
	freqreference = unpack('1I', data[1052:1056])
	trigmode = unpack('1I', data[1056:1060])
	trigsource = unpack('1I', data[1060:1064])
	trigtrans = unpack('1I', data[1064:1068])
	triglevel = unpack('1d', data[1068:1076])
	instrumentstate = {'referencelevel': referencelevel, 'centerfrequency': centerfrequency,
		'temperature': temperature, 'alignment': alignment, 'freqreference': freqreference,
		'trigmode': trigmode, 'trigsource': trigsource, 'trigtrans': trigtrans,
		'triglevel': triglevel}

	# Get and print Data Format section of the header
	datatype = unpack('1I', data[2048:2052])
	#frameoffset = unpack('1I', data[2052:2056])
	frameoffset = np.fromstring(data[2052:2056], dtype = np.uint32)
	#framesize = unpack('1I', data[2056:2060])
	framesize = np.fromstring(data[2056:2060], dtype = np.uint32)
	sampleoffset = unpack('1I', data[2060:2064])
	framesamples = unpack('1I', data[2064:2068])
	#nonsampleoffset = unpack('1I', data[2068:2072])
	nonsampleoffset = np.fromstring(data[2068:2072], dtype = np.uint32)
	#nonframesamples = unpack('1I', data[2072:2076])
	nonframesamples = np.fromstring(data[2072:2076], dtype = np.uint32)
	ifcenterfrequency = np.fromstring(data[2076:2084], dtype = np.double)
	samplerate = unpack('1d', data[2084:2092])
	bandwidth = unpack('1d', data[2092:2100])
	corrected = unpack('1I', data[2100:2104])
	timetype = unpack('1I', data[2104:2108])
	reftime = unpack('7i', data[2108:2136])
	timesamples = unpack('1Q', data[2136:2144])
	#timesamplerate = unpack('1Q', data[2144:2152])
	timesamplerate = np.fromstring(data[2144:2152], dtype = np.uint64)
	dataformat = {'datatype': datatype, 'frameoffset': frameoffset, 'framesize':framesize,
		'sampleoffset':sampleoffset, 'framesamples': framesamples, 'nonsampleoffset': nonsampleoffset,
		'nonframesamples': nonframesamples, 'ifcenterfrequency': ifcenterfrequency,
		'samplerate': samplerate, 'bandwidth': bandwidth, 'corrected': corrected,
		'timetype': timetype, 'reftime': reftime, 'timesamples': timesamples,
		'timesamplerate': timesamplerate}

	# Get Signal Path and Channel Correction data
	adcscale = np.fromstring(data[3072:3080], dtype = np.double)
	pathdelay = np.fromstring(data[3080:3088], dtype = np.double)
	correctiontype = np.fromstring(data[4096:4100], dtype = np.uint32)
	tableentries = np.fromstring(data[4352:4356], dtype = np.uint32)
	freqindex = 4356
	phaseindex = freqindex + 501*4
	ampindex = phaseindex + 501*4
	freqtable = np.fromstring(data[freqindex:(freqindex+tableentries*4)], dtype = np.float32)
	amptable = np.fromstring(data[phaseindex:(phaseindex+tableentries*4)], dtype = np.float32)
	phasetable = np.fromstring(data[ampindex:(ampindex+tableentries*4)], dtype = np.float32)
	channelcorrection = {'adcscale': adcscale, 'pathdelay': pathdelay, 
		'correctiontype':correctiontype, 'tableentries': tableentries, 
		'freqtable': freqtable, 'amptable': amptable, 'phasetable': phasetable}
	
	metadata = {'versioninfo': versioninfo, 'instrumentstate': instrumentstate,
		'dataformat': dataformat, 'channelcorrection': channelcorrection}

	# Depending on the status of 'display,' display metadata, 
	# correction plots, both, or neither
	if display == 3:
		print_metadata(metadata)
		plot_graphs(metadata)
	elif display == 2:
		print('\nChannel correction graphs plotted.')
		plot_graphs(metadata)
	elif display == 1:
		print_metadata(metadata)
		print('\nMetadata parsed and printed.')
	elif display == 0:
		print('\nData parsed.')
	else: 
		print('Invalid choice for \'metadisplay\' variable. Select 0, 1, 2, or 3.')

	return metadata
filename = 'C:\\SignalVu-PC Files\\parser\\cw1ghz.r3f'
metadisplay = 1
metadata = get_header_data(filename, metadisplay)
"""
t0 = time.clock()
data = open(filename, 'rb')
print('Time to open file is %f' % (time.clock()-t0))
t0 = time.clock()
data = np.fromfile(filename, dtype = np.int16)
print('Time to open file in numpy is %f' % (time.clock() - t0))
"""

filesize = os.path.getsize(filename)
print(filesize)

numframes = (filesize/metadata['dataformat']['framesize']) - 1
print('Number of Frames: %d' % numframes)
data.seek(metadata['dataformat']['frameoffset'])
adcdata = np.zeros([numframes*metadata['dataformat']['framesize']])
rawdata = metadata['dataformat']['nonsampleoffset']
footerdata = metadata['dataformat']['nonframesamples']
framesize = metadata['dataformat']['framesamples']

for i in range(0,numframes):
	frame = data.read(rawdata)
	data.seek(footerdata,1)
	adcdata[i] = np.fromstring(frame, dtype = np.int16)

adcdata = adcdata*metadata['channelcorrection']['adcscale']
t1 = time.clock()
print('Time to read and strip data is %f' % (t1-t0))
