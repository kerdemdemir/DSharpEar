module config.config;

import std.math;

alias SharpVector = float[];
enum float SOUND_SPEED = 34300.0;



class Config 
{
public:
	static Config singleton()
	{
		static Config instance;
		if ( !instance )
			instance = new Config();
 		return instance;
	}

	int getMicMaxDelay() const
	{
		float totalMicLen = arraySize * (distBetweenMics - 1) / 2.0;
		return cast(int)(totalMicLen / SOUND_SPEED * cast(float)samplePerSecond);
	}

	size_t samplePerSecond;
	size_t arraySize;
	size_t distBetweenMics;
	size_t packetSize;
}

