module microphone.microphone;

import std.array;
import std.range;
import std.math;
import std.algorithm;
import config.config;


class Microphone
{
public:
	this( float distCenter )
	{
		m_distCenter = distCenter;
		m_data.length = Config.singleton().packetSize;
		m_leapTotalData.length = Config.singleton().getMicMaxDelay * 2;
		clearData();
	}

	float getSteeringDelay(float steeringAngle) const
	{
		float returnVal = -m_distCenter * sin(steeringAngle * std.math.PI / 180.0) / SOUND_SPEED * cast(float)Config.singleton().samplePerSecond;
		return returnVal;
	}

	float getFocusDelay(float focusDist) const
	{
		float returnVal = (std.math.pow(m_distCenter, 2) / (2.0 * focusDist)) / SOUND_SPEED * cast(float)Config.singleton().samplePerSecond;
		return returnVal;
	}

	float getDelay(float focusDist, float steeringAngle) const
	{
		return getFocusDelay(focusDist) + getSteeringDelay(steeringAngle);
	}


	void feed( const SharpVector input, float focusDist, float steeringAngle, int speakerID)
	{
		size_t delay = cast(int) (getDelay(focusDist, steeringAngle) + Config.singleton().getMicMaxDelay());
		SharpVector tempLeap = getLeapIter(speakerID, delay);
		for (size_t k = 0; k < m_data.length + delay; k++)
		{
			if (k < delay)
			{
				m_data[k] += tempLeap[k];
			}
			else if (k < m_data.length)
			{
				m_data[k] += input[k - delay];
			}
			else
			{
				float soundData = input[k - m_data.length];
				tempLeap[k - m_data.length] = soundData;
				m_leapTotalData[k - m_data.length] += soundData;
			}
		}
	}

	SharpVector getLeapIter(int speakerID, float delay)
	{
		SharpVector* p;
		p = (speakerID in m_leapData);
		if (p !is null)
		{
			return *p;
		}
		else 
		{
			SharpVector newLeapData;
			newLeapData.length = cast(int)delay;
			newLeapData.fill( 0 );
			m_leapData[speakerID] = newLeapData;
			return newLeapData;
		}
	}


	void clearData()
	{
		m_data.fill( 0 );
		m_leapTotalData.fill( 0 );
	}

	void clearLeapData()
	{
		m_leapData.clear();
	}

	SharpVector getData() 
	{
		return m_data;
	}

	SharpVector getLeapData()
	{
		return m_leapTotalData;
	}

	float getData(size_t index) const
	{
		if (m_data.length > index)
		{
			return m_data[index];
		}
		else
		{
			auto leapIndex = index - m_data.length;
			return m_leapTotalData[leapIndex];
		}
	}

private:

	float m_distCenter;
	SharpVector[int]  m_leapData; // Leap Data for each source
	SharpVector m_leapTotalData; // Leap Data for each source
	SharpVector m_data;
};
