module microphone.microphoneArray;

import microphone.microphone;
import config.config;
import std.algorithm;


class MicrophoneArray
{
public:
	this()
	{
		ulong arraySize = Config.singleton().arraySize;
		float elemDistFromMid = arraySize/2; 
		for (int i = 0; i < arraySize; i++)
		{
			if (arraySize % 2 == 0)
			{
				micropshoneList ~= new Microphone((float(i - elemDistFromMid) + 0.5) * Config.singleton().distBetweenMics);
			}
			else
			{
				micropshoneList ~= new Microphone((float(i - elemDistFromMid)) * Config.singleton().distBetweenMics);
			}
		}	
	}

	void InsertSound( const float[] rawData, float focusDist, float steerAngle )
	{
		for (size_t i = 0; i < micropshoneList.length ; i++)
		{
			micropshoneList[i].feed(rawData, focusDist, steerAngle, 0);
		}
	}

	void Beamform( float[] outputData, float focusDist, float steerAngle)
	{
		outputData.map!(a => a = 0);
		for (size_t i = 0; i < Config.singleton().packetSize ; i++)
		{
			foreach ( microphone ; micropshoneList)
			{
				int delay = cast(int)(microphone.getDelay(focusDist, steerAngle) + Config.singleton().getMicMaxDelay());
				outputData[i] += microphone.getData(delay + i);
			}
			outputData[i] /= Config.singleton().arraySize;
		}	
	}

	Microphone[] micropshoneList;
};
