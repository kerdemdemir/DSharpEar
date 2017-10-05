import std.stdio;
import microphone.microphoneArray;
import config.config;
import std.math;
import std.algorithm;


int createPulse(SharpVector data, size_t readSize, float sampleRate)
{
	float f0 = 1500;
	float ts = 1.0 / sampleRate;

	for (size_t i = 0; i < readSize; i++)
	{
		float realTime = i  * ts;
		float realPart = cos(2.0*std.math.PI*realTime*f0);
		data[i] = realPart;
	}
	return data.length;
}


int main(string[] argv)
{ 
	Config ins = Config.singleton();

	ins.samplePerSecond = 44000;
	ins.arraySize = 32;
	ins.distBetweenMics = 10;
	ins.packetSize = 44000;

	MicrophoneArray array = new MicrophoneArray();
	SharpVector rawData;
	rawData.length = ins.packetSize;
	createPulse(rawData, 44000, 44000);
	array.InsertSound(rawData, 1000, 45);
	SharpVector outputData;
	outputData.length = ins.packetSize;
	outputData.fill(0);
	array.Beamform(outputData, 1000, 45); 

    return 0; 
}
